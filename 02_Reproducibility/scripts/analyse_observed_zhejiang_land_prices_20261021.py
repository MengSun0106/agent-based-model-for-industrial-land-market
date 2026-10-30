"""Describe observed Zhejiang industrial-land prices; no policy effect is estimated.

Main statistic: the equal-weight mean of 11 city means of parcel unit prices.
Records are nominal transactions, not deflated prices or quality-adjusted indices.
The parcel-level source file is not included in this release. Supply it explicitly
with --input to reproduce the processed tables; outputs default to this package.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

import numpy as np
import pandas as pd


PACKAGE = Path(__file__).resolve().parents[2]
DEFAULT_OUT = PACKAGE / "results/recomputed_observed_land_prices"
USES = {"工业用地", "一类工业用地", "二类工业用地", "三类工业用地"}
COLUMNS = [
    "年份", "供地全局唯一标志符", "宗地全局唯一标志符", "省", "市", "市代码",
    "土地用途", "供地方式", "供地面积_公顷", "成交价格_万元",
]


def checksum(path):
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def analyse(input_path, output):
    collected = []
    for chunk in pd.read_csv(input_path, usecols=COLUMNS, chunksize=50_000,
                             low_memory=False, encoding="utf-8-sig"):
        years = pd.to_numeric(chunk["年份"], errors="coerce")
        collected.append(chunk.loc[chunk["省"].eq("浙江省")
                                   & years.between(2013, 2024)].copy())
    data = pd.concat(collected, ignore_index=True)
    audit = [{"stage": "Zhejiang records, 2013–2024", "records": len(data)}]

    data["year"] = pd.to_numeric(data["年份"], errors="coerce")
    data["area_ha"] = pd.to_numeric(data["供地面积_公顷"], errors="coerce")
    data["price_10k"] = pd.to_numeric(data["成交价格_万元"], errors="coerce")
    data["city_code"] = pd.to_numeric(data["市代码"], errors="coerce")
    use = data["土地用途"].fillna("").astype(str).str.strip()
    data = data.loc[use.isin(USES)].copy()
    audit.append({"stage": "Industrial-use categories only", "records": len(data)})

    method = data["供地方式"].fillna("").astype(str).str.strip()
    is_conveyance = method.str.contains("出让|协议|招标|拍卖|挂牌", regex=True)
    excluded = method.str.contains("划拨|租赁|授权经营|作价出资", regex=True)
    data = data.loc[is_conveyance & ~excluded].copy()
    audit.append({"stage": "Conveyance, excluding allocation/lease/equity contribution",
                  "records": len(data)})
    data = data.loc[data.area_ha.gt(0) & data.price_10k.gt(0)
                    & data.city_code.notna()].copy()
    audit.append({"stage": "Positive price and area; valid city code", "records": len(data)})

    parcel = data["宗地全局唯一标志符"].fillna("").astype(str).str.strip()
    supply = data["供地全局唯一标志符"].fillna("").astype(str).str.strip()
    data["record_key"] = np.where(parcel.ne(""), "P:" + parcel,
                                   np.where(supply.ne(""), "S:" + supply, ""))
    duplicate = data.record_key.ne("") & data.duplicated("record_key", keep="first")
    duplicates_removed = int(duplicate.sum())
    data = data.loc[~duplicate].copy()
    audit.append({"stage": "Unique parcel ID, supply ID fallback; empty IDs retained",
                  "records": len(data)})
    data["unit_price"] = data.price_10k / data.area_ha
    data = data.loc[np.isfinite(data.unit_price) & data.unit_price.gt(0)].copy()
    audit.append({"stage": "Finite positive unit prices", "records": len(data)})
    data["year"] = data.year.astype(int)
    data["city_code"] = data.city_code.astype(int)

    # Alternative summaries are documented, not selected by their policy implications.
    lower = data.groupby("year").unit_price.transform(lambda x: x.quantile(.01))
    upper = data.groupby("year").unit_price.transform(lambda x: x.quantile(.99))
    data["winsorized_price"] = data.unit_price.clip(lower=lower, upper=upper)
    city = data.groupby(["year", "city_code", "市"], as_index=False).agg(
        parcel_records=("unit_price", "size"),
        mean_price=("unit_price", "mean"),
        median_price=("unit_price", "median"),
        winsorized_mean_price=("winsorized_price", "mean"),
        total_area_ha=("area_ha", "sum"),
        total_price_10k=("price_10k", "sum"),
    ).rename(columns={"市": "city"})
    city["area_weighted_price"] = city.total_price_10k / city.total_area_ha
    assert len(city) == 132
    assert not city.duplicated(["city_code", "year"]).any()
    assert city.groupby("year").city_code.nunique().eq(11).all()
    annual = city.groupby("year", as_index=False).agg(
        cities=("city_code", "nunique"),
        parcel_records=("parcel_records", "sum"),
        mean_city_price=("mean_price", "mean"),
        mean_city_median_price=("median_price", "mean"),
        mean_city_winsorized_price=("winsorized_mean_price", "mean"),
        mean_city_area_weighted_price=("area_weighted_price", "mean"),
        total_area_ha=("total_area_ha", "sum"),
        total_price_10k=("total_price_10k", "sum"),
    )
    annual["province_area_weighted_price"] = annual.total_price_10k / annual.total_area_ha
    annual["province_parcel_mean_price"] = data.groupby("year").unit_price.mean().reindex(
        annual.year).to_numpy()
    endpoints = annual.set_index("year")
    first, last = float(endpoints.loc[2013, "mean_city_price"]), float(
        endpoints.loc[2024, "mean_city_price"])
    increase = 100 * (last / first - 1)
    by_city = city.pivot(index="city_code", columns="year", values="mean_price")
    assert (by_city[2024] > by_city[2013]).all()
    # Independently reproduce the main statistic directly from filtered records.
    check = data.groupby(["year", "市"]).unit_price.mean().groupby("year").mean()
    assert np.allclose(annual.mean_city_price, check.reindex(annual.year))

    output.mkdir(parents=True, exist_ok=True)
    city.to_csv(output / "zhejiang_city_year_prices_2013_2024.csv", index=False,
                encoding="utf-8-sig", float_format="%.10f")
    annual.to_csv(output / "zhejiang_annual_prices_2013_2024.csv", index=False,
                  encoding="utf-8-sig", float_format="%.10f")
    pd.DataFrame(audit).to_csv(output / "filter_audit.csv", index=False,
                                encoding="utf-8-sig")
    provenance = {
        "source": str(input_path.resolve()), "source_sha256": checksum(input_path),
        "source_description": "Author-provided parcel-level land-conveyance records",
        "years": [2013, 2024], "province": "Zhejiang", "cities": 11,
        "city_year_observations": len(city), "valid_records": len(data),
        "duplicates_removed": duplicates_removed, "industrial_categories": sorted(USES),
        "unit": "CNY 10,000 per hectare, numerically equal to CNY per square metre",
        "price_basis": "Nominal transaction prices; not deflated or quality-adjusted",
        "main_statistic": "Arithmetic mean of parcel unit prices within each city-year, "
                          "then equal-weight mean across the same 11 cities each year",
        "unit_price_definition": "transaction price (CNY 10,000) / parcel area (hectares)",
        "first_mean": first, "last_mean": last, "percentage_increase": increase,
        "inference": "Descriptive time trend, not an identified effect of either policy",
        "cooperation_evidence": {
            "Li_2025": "Section 5.3 and Figure 4: post-pairing increases in intercounty "
                       "investment persist beyond initial designation; this is not a "
                       "survival estimate for individual enclave ties.",
            "Zhang_2023": "Case description p.1734: park jointly established August 2013; "
                          "p.1737 reports 2020 industrial output. Continued park activity "
                          "does not measure the survival of all provincial partnerships.",
        },
    }
    (output / "provenance.json").write_text(json.dumps(provenance, ensure_ascii=False,
                                                      indent=2) + "\n", encoding="utf-8")
    print(annual.round(3).to_string(index=False))
    print(f"Valid records: {len(data)}; city-years: {len(city)}; removed duplicates: {duplicates_removed}")
    print(f"Main mean: {first:.10f} -> {last:.10f}; change: {increase:.10f}%")
    print(f"Saved: {output}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--input", type=Path, required=True,
        help="Path to the original parcel-level China Land Market CSV (not included in this package).",
    )
    parser.add_argument("--output", type=Path, default=DEFAULT_OUT)
    args = parser.parse_args()
    analyse(args.input, args.output)
