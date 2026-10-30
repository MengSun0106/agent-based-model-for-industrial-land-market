; Required extensions are included with the standard NetLogo distribution.
extensions [table gis]



globals [
        land_cost_series
        resource_com_series
        tech_com_series
        run-number
        real_governments
        total_industrial_land_quota_year

        total_environment
        investment-timer

        map-layer
        gem
        quota_share
        gem-list
        boundary
        valid-patches
        top_gov

        total_company_number

        model1
        model2
        model3
        model4

        all_same?
        top_10_percent_govs
        top_10_agentset
        top_innovation_rely
        policy-duration

        avg_initial_profit
        ]

breed [local_governments local_government]
breed [industrial_companies industrial_company]

patches-own [city-name companies_num tech_num res_num area1
             industrial_land_price-p
             innovation_cost-p
             total_cost-p
             here1


             ]

local_governments-own[
  industrial_land_price
  GDP
  money
  budget_money
  industrial_quota
  quota_share_already
  top_10_local_governments

  GDP_per


  related_patches
  related-companies
  potential_cooperate

  land_rely
  innovation_rely
  innovation_money
  land_cost
  land_cost_initial
  land_money
  innovation_cost
  total_cost
  top?
  profit
 ; innovation_investments
 ; valid_innovation_money
 ; innovation_money_table
  innovation_investments
  company_number
  last_company_number
  initial_quota_year
  cooperate
  count_cooperate_time
  partner
  real
  industrial_park
  industrial_park_positive
  industrial_park_negetive
  industrial_park_quota
  here
  now_park
  developing_cultivated_land
  quota_transition
  inf_investment
  sci_investment
  inf_proportion
  sci_proportion
  sevice_investment
  value_preference
  land_quota_proportion
  city-name1
  city-name2
  city-name3
  city-name11
  city-name12
  area
  industrial_land_price_per
  patch-name
  area_patches
  industrial_land_transfered
  industrial_land_transfered_total
  instrial_land_priceo
  lowest_price_control
  land_area
  gdp_companies
  money_minus
  price_minus
  valid_innovation_money
  modification_factor
  enclave_active
  cooperation_years
  enclave_origin_opportunity_3y
  enclave_host_opportunity_3y
  enclave_origin_benefit_3y
  enclave_host_benefit_3y
  enclave_expansion_round
  enclave_host_share
  enclave_provincial_quota_support
  enclave_host_quota_support
  enclave_age
  tenglong_threshold
  transaction_cost_rate
  modification_factor_resource
  modification_factor_innovation
  want_host
]


industrial_companies-own[
  state
  active
  gdp_devotion
  tax_devotion
  land_preference
  innovation_preference
  check_state
  check_state_quota
  check_state_tax
  highest_preference
  company-id
  land_use
  type1
  ;lowest_cost
  ;lowest_cost_gov
  new_hatch
  minimum_tax
  tax_hecture
  age
  life
  invest-time
  target_patch
  target_patch1
  target_gov
  lowest_cost_gov
  lowest_cost
  second_lowest_cost
  second_lowest_cost_gov
  third_lowest_cost
  third_lowest_cost_gov
  fourth_lowest_cost
  fourth_lowest_cost_gov
  fifth_lowest_cost
  fifth_lowest_cost_gov
  sixth_lowest_cost
  sixth_lowest_cost_gov
  seventh_lowest_cost
  seventh_lowest_cost_gov
  eightth_lowest_cost
  eightth_lowest_cost_gov
  nineth_lowest_cost
  nineth_lowest_cost_gov
  tenth_lowest_cost
  tenth_lowest_cost_gov
  eleventh_lowest_cost
  eleventh_lowest_cost_gov

  target_patch1-1
  target_patch2
  target_patch3
  target_patch4
  target_patch5
  target_patch6
  target_patch7
  target_patch8
  target_patch9
  target_patch10
  target_patch11
  twelfth_lowest_cost
  thirteenth_lowest_cost
  fourteenth_lowest_cost
  target_patch12
  target_patch13
  target_patch14
  twelfth_lowest_cost_gov
  thirteenth_lowest_cost_gov
  fourteenth_lowest_cost_gov
  host_quota_ratio_at_entry
]







to setup
  clear-all
  ifelse seed_value > 0 [
    random-seed seed_value
  ] [
    random-seed new-seed
  ]
  reset-ticks
   ; file-delete "turtle_data_run_0.csv"
  ; file-delete "turtle_data_per_tick2.csv"
  ; file-delete "turtle_data_per_tick3.csv"
  ; file-delete "turtle_data_per_tick4.csv"
  set policy-duration 50
  set model1 ifelse-value (scenario = 1) [1] [0]
  set model2 ifelse-value (scenario = 2) [1] [0]
  set model3 ifelse-value (scenario = 3) [1] [0]
  set model4 ifelse-value (scenario = 4) [1] [0]
  set land_cost_series [ 272 	257 508 264 298 362 376 444 506 535 578 617 ]
  set resource_com_series [99 90 76 80 99 60 65 106 113 103 45]
  set tech_com_series [46 45 38 42 44 44 55 112 117 97 46]
  ; Find the supplied GIS file whether it is beside this model, in a nearby
  ; gis/ folder, or in the release package's sibling gis/ folder.
  ; The Chinese DBF field names below are data keys and must remain unchanged.
  let gis-file "浙江地级市新新.shp"
  let gis-path ""
  ifelse file-exists? gis-file [
    set gis-path gis-file
  ] [
    ifelse file-exists? (word "gis/" gis-file) [
      set gis-path (word "gis/" gis-file)
    ] [
      ifelse file-exists? (word "../gis/" gis-file) [
        set gis-path (word "../gis/" gis-file)
      ] [
        error "GIS shapefile not found. Place 浙江地级市新新.shp beside this model or in the supplied gis/ folder."
      ]
    ]
  ]
  set gem gis:load-dataset gis-path
  gis:set-world-envelope gis:envelope-of gem
  set boundary gis:envelope-of gem

  gis:draw gem 0
  gis:set-drawing-color black
  set gem-list gis:feature-list-of gem
  gis:apply-coverage gem "ENG_NAME" city-name;
  gis:apply-coverage gem "技术密" tech_num
  gis:apply-coverage gem "资源密" res_num
  gis:apply-coverage gem "规模企" companies_num
  gis:apply-coverage gem "规模企" companies_num


  create-local_governments length gem-list [
    set shape "house"
    set color gray
    set real 1
    set here 0
    set quota_share 0
    set industrial_park 0
    set industrial_park_quota 0
    set city-name2 ""
    set industrial_land_transfered 0
    set industrial_land_transfered_total 0
    let feature item who gem-list
    set gdp gis:property-value feature "生总值"
  ;  set gdp ( gdp * 10000)
    set city-name1 gis:property-value feature "ENG_NAME"
    set instrial_land_priceo gis:property-value feature "工价"
    set lowest_price_control gis:property-value feature "最低价"
    set modification_factor gis:property-value feature  "修正系";
    set enclave_active 0
    set cooperation_years 0
    set enclave_origin_opportunity_3y 0
    set enclave_host_opportunity_3y 0
    set enclave_origin_benefit_3y 0
    set enclave_host_benefit_3y 0
    set enclave_expansion_round 0
    set enclave_host_share 0.6
    set enclave_provincial_quota_support 0
    set enclave_host_quota_support 0
    set enclave_age 0
    set tenglong_threshold 0
    set modification_factor_resource 1.0
    set modification_factor_innovation 1.0
    set land_cost gis:property-value feature "土开本"
    set land_cost_initial land_cost
    set last_company_number 0
    set initial_quota_year 0
    set want_host 0
   ; set money 5897609
   ; set budget_money 3835052

    set budget_money ((gis:property-value feature "科技投") + (gis:property-value feature "教育投") + (gis:property-value feature "基建投"))
    set money 0
    set money_minus 0
    set price_minus 0
    set industrial_land_price gis:property-value feature "工价"
    set inf_investment gis:property-value feature "基建投"
    set sci_investment gis:property-value feature "科技投"
    set area gis:property-value feature "城面积"

    set area area * 100
    set profit  ( instrial_land_priceo - land_cost )
    set innovation_rely (((gis:property-value feature "科技投") + (gis:property-value feature "教育投")) / ((gis:property-value feature "科技投") + (gis:property-value feature "教育投") + (gis:property-value feature "基建投")))
    set land_rely (1 - innovation_rely)
;    set land_money ( land_rely * money)
    set innovation_money (innovation_rely * money )
;    set value_preference (innovation_money / land_money)
    set land_quota_proportion gis:property-value feature "建地比"
    set land_area (area * land_quota_proportion)
;
    let centroid gis:location-of gis:centroid-of feature
    setxy first centroid last centroid

  ;  set valid_innovation_money 0
     set innovation_investments []

   ; set innovation_money_table table:make
    set innovation_cost 13000
    ;set innovation_money 0
    ;set valid_innovation_money 0
;    table:put innovation_money_table  "time" 0
;    table:put innovation_money_table "valid" 0
;    table:put innovation_money_table  "money1" innovation_money
;    table:put innovation_money_table "valid_innovation_money" 0

  ]

  set avg_initial_profit mean [profit] of local_governments with [real = 1]
  ask local_governments with [real = 1] [
    set profit avg_initial_profit
  ]

  ask patches [
  if companies_num = nobody [
      set res_num 0
      set tech_num 0
      set companies_num 0
  ]
]



 set valid-patches patches with [
    not (city-name = "") and
    companies_num > 0
  ]

 ask  valid-patches [
    set pcolor white
  ]


  let city-list remove-duplicates [city-name] of valid-patches

  foreach city-list [
    city-name-current ->
    let city-patches valid-patches with [city-name = city-name-current]


    let total-res-companies  mean[res_num] of city-patches
  ;  set total-res-companies total-res-companies * 2
    let total-tech-companies mean[tech_num] of city-patches
  ;  set total-tech-companies total-tech-companies * 2

    if total-tech-companies > 0 [
      create-industrial_companies total-tech-companies [
        set company-id who
        set type1 1
        move-to one-of city-patches
        set active 0
        set color green
        set size 1
        set shape "circle"
        set innovation_preference ( (random-float 0.1 ) + 0.8)
        set land_preference (1 - innovation_preference )
        set gdp_devotion (random-float 0.3 + 0.34 ) * 10000
        set tax_devotion ( random 800 + 950 )
        set land_use 1.60
        set highest_preference ( random 2000 + 8000 )  ; Integer threshold: 8,000–9,999.
        set check_state 0
        set check_state_quota 0
        set check_state_tax 0
        set state 0
        set minimum_tax 670
        set life (random 3 + 4 )
      ]
    ]

    if total-res-companies > 0 [
      create-industrial_companies total-res-companies [
        set company-id who
        move-to one-of city-patches
        set active 0
        set type1 0
        set color red
        set size 1
        set shape "circle"
        set land_preference ( (random-float 0.1 ) + 0.4)
        set innovation_preference (1 - land_preference )
        set gdp_devotion (random-float 0.12 + 0.136) * 10000


        set tax_devotion  ( random 300 + 350 )
        set land_use 2.74
        set highest_preference ( random 2000 + 2600 )  ; Integer threshold: 2,600–4,599.
        set check_state 0
        set check_state_quota 0
        set check_state_tax 0
        set state 0
        set minimum_tax 266
        set life (random 4 + 5 )
      ]
    ]
  ]
   reset-ticks
end




to setup-runs
  let steps 100
  let runs  50

;  file-delete "turtle_data_model1.csv"
;  file-delete "turtle_data_model2.csv"
;  file-delete "turtle_data_model3.csv"
;  file-delete "turtle_data_model4.csv"

  foreach [1 2 3 4] [
    s ->
    set scenario s
    set run-number 1

    repeat runs [
      setup
      run-simulation steps
      set run-number run-number + 1
    ]
  ]
end


to run-simulation [steps]


  repeat steps [
    if scenario = 1 [ go1 ]
    if scenario = 2 [ go2 ]
    if scenario = 3 [ go3 ]
    if scenario = 4 [ go4 ]
  ]

  file-close
end

to go
  if scenario = 1 [ go1 ]
  if scenario = 2 [ go2 ]
  if scenario = 3 [ go3 ]
  if scenario = 4 [ go4 ]
end

to go-withdrawal
  let current-tick ticks

  ifelse current-tick < policy-duration [
    if scenario = 1 [ go1 ]
    if scenario = 2 [ go2 ]
    if scenario = 3 [ go3 ]
    if scenario = 4 [ go4 ]
  ] [
    go1
  ]
end


to go1

     set_change
     hatch_com
     calculation
     sort_government
     quota_allocation
     value_change1
     development_plan

repeat 12 [
     value_change1
     calculation_gdp
     intergovernmental_competation
     investment_attraction
     check-company-life
     investment_growth_hatch
  ]

     industrial_relocation
     refresh-output-metrics
     save_file1
tick
end

to go2

     set_change
     hatch_com
     calculation
     sort_government
     quota_allocation
     value_change1
     development_plan

repeat 12 [
     value_change1
     calculation_gdp
     update-standard-land-modification-factor
     intergovernmental_competation
     investment_attraction_biaozhundi
     check-company-life
     investment_growth_hatch
  ]
     industrial_relocation
     refresh-output-metrics
     save_file1
tick



end

to go3
    set_change
     hatch_com
     calculation1
     sort_government
     quota_allocation1
     value_change1
     development_plan1

  repeat 12 [
     value_change1
     calculation_gdp1
     intergovernmental_competation
     investment_attraction
     check-company-life
     investment_growth_hatch
  ]

     intergovernmental_cooperation
     industrial_relocation1
     refresh-output-metrics
     cooperation_change
     save_file1
tick

end

to go4
     set_change
     hatch_com
     calculation1
     sort_government
     quota_allocation1
     value_change1
     development_plan1

  repeat 12 [
     value_change1
     calculation_gdp1
     update-standard-land-modification-factor
     intergovernmental_competation
     investment_attraction_biaozhundi
     check-company-life
     investment_growth_hatch
  ]

     intergovernmental_cooperation
     industrial_relocation1
     refresh-output-metrics
     cooperation_change
     save_file1
tick
end

to refresh-output-metrics
  ask local_governments [
    let my-place [city-name] of patch-here
    set related-companies industrial_companies with [[city-name] of patch-here = my-place and state = 1]
    set gdp sum [gdp_devotion] of related-companies with [state = 1]
    set company_number count related-companies

    let my-city-name1 city-name1
    set area_patches count patches with [city-name = my-city-name1]
  ]

  ask local_governments with [industrial_park = 1] [
    let park-gdp gdp
    let park-company-number company_number

    ; city-name3 is the host/receiving government, city-name2 is the origin/sending government.
    let host-government-name city-name3
    let origin-government-name city-name2

    ask local_governments with [city-name1 = host-government-name and real = 1] [
      set gdp gdp + (park-gdp * enclave-host-share myself)
      set company_number company_number + (park-company-number * enclave-host-share myself)
    ]

    ask local_governments with [city-name1 = origin-government-name and real = 1] [
      set gdp gdp + (park-gdp * enclave-origin-share myself)
      set company_number company_number + (park-company-number * enclave-origin-share myself)
    ]
  ]

  ask local_governments [
    if industrial_land_transfered_total != 0 [
      set gdp_per gdp / industrial_land_transfered_total
    ]
    if industrial_land_transfered_total = 0 [
      set gdp_per 0
    ]
  ]
end

to update-standard-land-modification-factor
  ask local_governments with [real = 1] [
    let active-local-companies industrial_companies with [state = 1 and target_gov = myself]
    let resource-companies active-local-companies with [type1 = 0]
    let innovation-companies active-local-companies with [type1 = 1]

    if count resource-companies >= 4 [
      let resource-p25 percentile-25 [tax_hecture] of resource-companies
      let resource-mean-minimum-tax mean [minimum_tax] of resource-companies
      if resource-mean-minimum-tax > 0 [
        set modification_factor_resource max (list 0.9 (resource-p25 / resource-mean-minimum-tax))
      ]
    ]

    if count innovation-companies >= 4 [
      let innovation-p25 percentile-25 [tax_hecture] of innovation-companies
      let innovation-mean-minimum-tax mean [minimum_tax] of innovation-companies
      if innovation-mean-minimum-tax > 0 [
        set modification_factor_innovation max (list 0.9 (innovation-p25 / innovation-mean-minimum-tax))
      ]
    ]
  ]
end

to-report standard-land-modification-factor [gov company-agent]
  ; Enclave parks apply the current Standard Land rule of their host city.
  ; This prevents a park from retaining the host's threshold as it stood when
  ; the park agent was created.
  let standard-setting-government gov
  if [industrial_park] of gov = 1 [
    let host-government-name [city-name3] of gov
    let host-government one-of local_governments with [real = 1 and city-name1 = host-government-name]
    if host-government != nobody [
      set standard-setting-government host-government
    ]
  ]

  ifelse ([type1] of company-agent = 1) [
    report [modification_factor * modification_factor_innovation] of standard-setting-government
  ] [
    report [modification_factor * modification_factor_resource] of standard-setting-government
  ]
end

to-report percentile-25 [value-list]
  let sorted-values sort value-list
  let n length sorted-values
  if n = 0 [ report 0 ]
  let idx floor ((n - 1) * 0.25)
  report item idx sorted-values
end

to-report enclave-host-share [park-agent]
  report [enclave_host_share] of park-agent
end


to-report enclave-origin-share [park-agent]
  report (1 - [enclave_host_share] of park-agent)
end

to set_change
  if ticks < 12 [
    let land_cost_now item ticks land_cost_series
    ask local_governments [
      set land_cost land_cost_now
    ]
  ]
end

to-report initial-city-weight [government company-type]
  let government-name [city-name1] of government

  if company-type = 1 [
    if government-name = "Hangzhou" [ report 470 ]
    if government-name = "Ningbo" [ report 1022 ]
    if government-name = "Wenzhou" [ report 1541 ]
    if government-name = "Jiaxing" [ report 263 ]
    if government-name = "Huzhou" [ report 78 ]
    if government-name = "Shaoxing" [ report 349 ]
    if government-name = "Jinhua" [ report 387 ]
    if government-name = "Quzhou" [ report 50 ]
    if government-name = "Zhoushan" [ report 29 ]
    if government-name = "Taizhou" [ report 285 ]
    if government-name = "Lishui" [ report 86 ]
  ]

  if company-type = 0 [
    if government-name = "Hangzhou" [ report 348 ]
    if government-name = "Ningbo" [ report 2808 ]
    if government-name = "Wenzhou" [ report 1828 ]
    if government-name = "Jiaxing" [ report 647 ]
    if government-name = "Huzhou" [ report 193 ]
    if government-name = "Shaoxing" [ report 338 ]
    if government-name = "Jinhua" [ report 1181 ]
    if government-name = "Quzhou" [ report 100 ]
    if government-name = "Zhoushan" [ report 19 ]
    if government-name = "Taizhou" [ report 2297 ]
    if government-name = "Lishui" [ report 80 ]
  ]

  report 1
end




to-report previous-year-attraction-weight [government company-type]
  if ticks = 0 [
    report initial-city-weight government company-type
  ]

  let previous-year-count count industrial_companies with [
    state = 1 and
    target_gov = government and
    invest-time = (ticks - 1)
  ]

  if previous-year-count > 0 [
    report previous-year-count
  ]

  report initial-city-weight government company-type
end




to-report choose-spawn-government [company-type]
  let candidate-governments sort local_governments with [real = 1]
  let government-weights []

  foreach candidate-governments [ government-agent ->
    set government-weights lput (previous-year-attraction-weight government-agent company-type) government-weights
  ]

  let total-weight sum government-weights
  if total-weight <= 0 [
    report one-of candidate-governments
  ]

  let draw random-float total-weight
  let cumulative-weight 0
  let index 0

  while [index < length candidate-governments] [
    set cumulative-weight cumulative-weight + item index government-weights
    if draw <= cumulative-weight [
      report item index candidate-governments
    ]
    set index index + 1
  ]

  report last candidate-governments
end




to hatch_com
  let last-series-index ((length resource_com_series) - 1)
  let series-index min (list ticks last-series-index)
  let resource-count item series-index resource_com_series
  let tech-count item series-index tech_com_series

  create-industrial_companies tech-count [
    let spawn-government choose-spawn-government 1
    if spawn-government != nobody [
      let spawn-city-name [city-name1] of spawn-government
      let spawn-patches valid-patches with [city-name = spawn-city-name]
      if any? spawn-patches [
        move-to one-of spawn-patches
      ]
    ]
    set company-id who
    set active 0
    set type1 1
    set color green
    set size 1
    set shape "circle"
    set innovation_preference ((random-float 0.1) + 0.8)
    set land_preference (1 - innovation_preference)
    set gdp_devotion (random-float 0.3 + 0.34) * 10000
    set tax_devotion (random 800 + 950)
    set land_use 1.60
    set highest_preference (random 2000 + 8000)  ; Integer threshold: 8,000–9,999.
    set check_state 0
    set check_state_quota 0
    set check_state_tax 0
    set state 0
    set minimum_tax 670
    set life (random 3 + 4)
  ]

  create-industrial_companies resource-count [
    let spawn-government choose-spawn-government 0
    if spawn-government != nobody [
      let spawn-city-name [city-name1] of spawn-government
      let spawn-patches valid-patches with [city-name = spawn-city-name]
      if any? spawn-patches [
        move-to one-of spawn-patches
      ]
    ]
    set company-id who
    set active 0
    set type1 0
    set color red
    set size 1
    set shape "circle"
    set land_preference ((random-float 0.1) + 0.4)
    set innovation_preference (1 - land_preference)
    set gdp_devotion (random-float 0.12 + 0.136) * 10000
    set tax_devotion (random 300 + 350)
    set land_use 2.74
    set highest_preference (random 2000 + 2600)  ; Integer threshold: 2,600–4,599.
    set check_state 0
    set check_state_quota 0
    set check_state_tax 0
    set state 0
    set minimum_tax 266
    set life (random 4 + 5)
  ]
end




to calculation

    ask local_governments with [real = 1] [
    set money_minus money_minus + ( price_minus * industrial_land_transfered  * 0.1)
    set industrial_land_transfered 0
    set gdp 0
    set industrial_land_transfered 0
    set money money + budget_money - money_minus
    set money_minus 0
    set price_minus 0
    let my-place [city-name] of patch-here
 ;   show ( my-place)
    set related-companies industrial_companies with [ [city-name] of patch-here = my-place  and state = 1   ]
    ask related-companies[
   ;   show [city-name] of patch-here
    ]
    set gdp sum [gdp_devotion] of related-companies with [state = 1 ]
    let my-city-name1 [ city-name1] of self
    set area_patches count patches with  [ city-name = my-city-name1 ]
    if industrial_land_transfered_total != 0 [
      set gdp_per gdp / industrial_land_transfered_total
    ]
    if industrial_land_transfered_total = 0 [
      set gdp_per 0
    ]
    set money  money + ( sum [tax_devotion] of related-companies with [state = 1] )
 ;   set land_money ( land_rely * money)
;    show (word " land_money :" land_money )
;    set innovation_money ( innovation_rely * money)
  ;  show (word "Local Government at " my-place " has gdp: " gdp " and money: " money)
  ]


end



to calculation_gdp

    ask local_governments[
    set gdp 0

    let my-place [city-name] of patch-here
 ;   show ( my-place)
    set related-companies industrial_companies with [ [city-name] of patch-here = my-place  and state = 1   ]
    ask related-companies[
   ;   show [city-name] of patch-here
    ]
    set gdp sum [gdp_devotion] of related-companies with [state = 1 ]
    let my-city-name1 [ city-name1] of self
    set area_patches count patches with  [ city-name = my-city-name1 ]
    if industrial_land_transfered_total != 0 [
      set gdp_per gdp / industrial_land_transfered_total
    ]
    if industrial_land_transfered_total = 0 [
      set gdp_per 0
    ]

 ;   set land_money ( land_rely * money)
;    show (word " land_money :" land_money )
;    set innovation_money ( innovation_rely * money)
  ;  show (word "Local Government at " my-place " has gdp: " gdp " and money: " money)
  ]


end


to calculation_gdp1

    ask local_governments[
    set gdp 0

    let my-place [city-name] of patch-here
    set related-companies industrial_companies with [ [city-name] of patch-here = my-place  and state = 1]

    set gdp sum [gdp_devotion] of related-companies with [state = 1 ]
    let my-city-name1 [ city-name1] of self
    set area_patches count patches with  [ city-name = my-city-name1 ]
 ;   set gdp_per gdp / area_patches
;    set land_money ( land_rely * money)
;    show (word " land_money :" land_money )
;    set innovation_money ( innovation_rely * money)
  ;  show (word "Local Government at " my-place " has gdp: " gdp " and money: " money)
  ]


    ask local_governments with [ industrial_park = 1 ][
      let gdp_plus [gdp] of self

;    show (word "gdp_plus:"    gdp_plus  )
;    show (word "money_plus:"    money_plus  )
;    show (word "11111:"city-name1 )
;    show ( city-name2)
    ask local_governments with [city-name1 = [city-name3] of myself ]  [
      if real = 1 [
;      show (word "44444" [city-name1] of myself)
;      show (word"22222:" city-name1)
      set GDP GDP + (gdp_plus * enclave-host-share myself )

      ]
    ]
    ask local_governments with [city-name1 = [city-name2] of myself ]  [
      if real = 1 [

;      show (word "33333:"city-name1)
;      show ( [city-name2] of myself )
     set GDP GDP + (gdp_plus * enclave-origin-share myself )

      ]
    ]
    set GDP 0
    set money 0

    ]
  ask local_governments with [ real = 1] [
    if industrial_land_transfered_total != 0 [
      set gdp_per gdp / industrial_land_transfered_total
    ]
    if industrial_land_transfered_total = 0 [
      set gdp_per 0
    ]
  ]



end



to calculation1
    ask local_governments[
    set gdp 0
    if real = 1 [
    set money_minus money_minus + ( price_minus * industrial_land_transfered  * 0.1)
    set industrial_land_transfered 0
    set money money + budget_money - money_minus
    set money_minus 0
    set price_minus 0
    ]
    let my-place [city-name] of patch-here
    set related-companies industrial_companies with [ [city-name] of patch-here = my-place  and state = 1]

    set gdp sum [gdp_devotion] of related-companies with [state = 1 ]
    let my-city-name1 [ city-name1] of self
    set area_patches count patches with  [ city-name = my-city-name1 ]
   ; set gdp_per gdp / area_patches
    set money  money + ( sum [tax_devotion] of related-companies with [state = 1] )
;    set land_money ( land_rely * money)
;    show (word " land_money :" land_money )
;    set innovation_money ( innovation_rely * money)
  ;  show (word "Local Government at " my-place " has gdp: " gdp " and money: " money)
  ]


    ask local_governments with [ industrial_park = 1 ][
      let gdp_plus [gdp] of self
      let money_plus [money] of self
;    show (word "gdp_plus:"    gdp_plus  )
;    show (word "money_plus:"    money_plus  )
;    show (word "11111:"city-name1 )
;    show ( city-name2)
    ask local_governments with [city-name1 = [city-name3] of myself ]  [
      if real = 1 [
;      show (word "44444" [city-name1] of myself)
;      show (word"22222:" city-name1)
      set GDP GDP + (gdp_plus * enclave-host-share myself )
     set money money + (money_plus * enclave-host-share myself)
      ]
    ]
    ask local_governments with [city-name1 = [city-name2] of myself ]  [
      if real = 1 [

;      show (word "33333:"city-name1)
;      show ( [city-name2] of myself )
     set GDP GDP + (gdp_plus * enclave-origin-share myself )
     set money money + (money_plus * enclave-origin-share myself )
      ]
    ]
    set GDP 0
    set money 0

    ]
ask local_governments with [ real = 1] [
    if industrial_land_transfered_total != 0 [
      set gdp_per gdp / industrial_land_transfered_total
    ]
    if industrial_land_transfered_total = 0 [
      set gdp_per 0
    ]
  ]


end


















to sort_government
  set real_governments local_governments with [real = 1]

  ask real_governments [
    set top? false
    set color gray
  ]

  set all_same? true
  if (count real_governments) > 1 [
    let first_gdp [gdp] of one-of real_governments
    ask real_governments [
      if gdp != first_gdp [
        set all_same? false
      ]
    ]
  ]
;
  if all_same? = false [
    let sorted-govs sort-on [gdp] real_governments
    let sorted-govs-reversed reverse sorted-govs
    let top-10-count ceiling ((count real_governments) * 0.1)

    set top_10_percent_govs sublist sorted-govs-reversed 0 top-10-count
    set top_gov first sorted-govs-reversed

    if top_gov != nobody [
      set top_innovation_rely ([innovation_rely] of top_gov)
      set top_10_agentset (turtle-set top_10_percent_govs)

      ask top_gov [
        set top? true
        set color red
      ]
    ]
  ]
end
;
;
to quota_allocation
  set total_industrial_land_quota_year ((random 30 + 60) * quota-scale)

  let base-quota 95
  let total-base (3 * count real_governments)
  let pool (total_industrial_land_quota_year * base-quota / 100 - total-base)
  let total-area sum [area] of real_governments
  ask real_governments[
    set industrial_quota industrial_quota + (3 + pool * area / total-area)
  ]

  if all_same? = false [
    let individual_reward  ( total_industrial_land_quota_year * 0.05 )
    if top_gov != nobody [
      ask top_gov [
        set industrial_quota industrial_quota + individual_reward
        set color red
      ]
    ]
  ]
  ask real_governments [
    set initial_quota_year industrial_quota
  ]

end
;

to quota_allocation1
  set total_industrial_land_quota_year ((random 30 + 60) * quota-scale)

  let base-quota 85
  let total-base (3 * count real_governments)
  let pool (total_industrial_land_quota_year * base-quota / 100 - total-base)
  let total-area sum [area] of real_governments
  ask real_governments [
    set industrial_quota industrial_quota + (3 + pool * area / total-area)
  ]

  if all_same? = false [
    let individual_reward (total_industrial_land_quota_year * 0.05)
    if top_gov != nobody [
      ask top_gov [
        set industrial_quota industrial_quota + individual_reward
        set color red
      ]
    ]
  ]

  ask real_governments [
    set initial_quota_year industrial_quota
  ]

end

to development_plan
 ask local_governments with [real = 1] [
  set land_money ( land_rely * money)
  set innovation_money (innovation_rely * money )
  set money 0
  set land_area ( land_area + ( land_money / land_cost ))
  set industrial_land_price_per ( land_cost + profit )
   ; show (word "name" city-name word "industrial_land_price: " industrial_land_price_per)
  set innovation_investments lput (list innovation_money ticks) innovation_investments
  local_endowment
  set innovation_cost innovation_cost - ( valid_innovation_money) * 0.09
 ;   show (word "name" city-name word "innovation_cost: " innovation_cost)
 ; set
  ]

end




to development_plan1
  ask local_governments with [real = 1] [
  set land_money ( land_rely * money)
  set innovation_money (innovation_rely * money )
  set money 0
  set land_area ( land_area + land_money / land_cost)
  set industrial_land_price_per ( land_cost + profit )
   ; show (word "name" city-name word "industrial_land_price: " industrial_land_price_per)
  set innovation_investments lput (list innovation_money ticks) innovation_investments
  local_endowment
  set innovation_cost innovation_cost - ( valid_innovation_money) * 0.09
;  show (word "name" city-name word "innovation_cost: " innovation_cost)
  ;  show (word "name1" city-name1 word "innovation_cost: " innovation_cost)
  ]


  ask local_governments with [ industrial_park = 1  ][
    ; city-name2 stores the origin/sending government of the enclave park.
    let origin-government-name city-name2
    let origin-government local_governments with [city-name1 = origin-government-name and real = 1]
    let industrial_land_price_per_list [industrial_land_price_per] of origin-government
    set industrial_land_price_per first industrial_land_price_per_list
    let innovation_cost_list [innovation_cost] of origin-government
    set innovation_cost first innovation_cost_list
  ]

end






;
to value_change

  ask local_governments [

    if top_innovation_rely != 0 [
      ;  show (word"innovation_rely:" innovation_rely)
        let innovation_distance (top_innovation_rely - innovation_rely)
      ;  show ( word "innovation_distance:" innovation_distance )
        set innovation_rely innovation_rely + (innovation_distance * value-influence )
        set land_rely ( 1 - innovation_rely )

    ]
      let my-place [city-name] of patch-here
      set related-companies industrial_companies with [ [city-name] of patch-here = my-place  and state = 1 ]

      let industries_count count related-companies
      if industries_count > 0 [
         let total_innovation_preference sum [innovation_preference] of related-companies
         let average_innovation_preference (total_innovation_preference / industries_count)
         let innovation_distance ( average_innovation_preference - innovation_rely )
         set innovation_rely innovation_rely + (innovation_distance * value-influence )
         set land_rely ( 1 - innovation_rely )

     ]

   ]




end




to value_change1

  ask local_governments with [real = 1][
    if top_innovation_rely != 0 [
        let innovation_distance (top_innovation_rely - innovation_rely)
        set innovation_rely innovation_rely + (innovation_distance * value-influence )
        set land_rely ( 1 - innovation_rely )

    ]
      let my-place [city-name] of patch-here
      set related-companies industrial_companies with [ [city-name] of patch-here = my-place and state = 1 ]

      let industries_count count related-companies
      if industries_count > 0 [
         let total_innovation_preference sum [innovation_preference] of related-companies
         let average_innovation_preference (total_innovation_preference / industries_count)
         let innovation_distance ( average_innovation_preference - innovation_rely )
         set innovation_rely innovation_rely + (innovation_distance * value-influence )
         set land_rely ( 1 - innovation_rely )

      ]
  ]
  ask local_governments [
    if   industrial_park  = 1[
     ; show ( city-name3 )
      let local_governments_target local_governments with  [city-name1 = [city-name2] of myself and real = 1]
      let local_governments_self   local_governments with  [city-name1 = [city-name3] of myself and real = 1]
      if (any? local_governments_target) and (any? local_governments_self) [
        let target-agent one-of local_governments_target
        let self-agent one-of local_governments_self
        let innovation_rely_target [ innovation_rely ] of target-agent
        let innovation_rely_self  [ innovation_rely ] of self-agent
        let innovation_difference  ( innovation_rely_target - innovation_rely_self )
        ask self-agent [
          set innovation_rely innovation_rely + (innovation_difference * value-influence )
          set land_rely ( 1 - innovation_rely )
        ]
      ]
    ]
  ]



end





to local_endowment
  set valid_innovation_money 0
  ask local_governments with [real = 1] [
    if not is-list? innovation_investments [
      set innovation_investments []
    ]
    let current-valid-investments 0
    foreach innovation_investments [
      investment-item ->
      let amount item 0 investment-item
      let year   item 1 investment-item

      let inv-age (ticks - year)
      if inv-age >= 3 [
        set current-valid-investments current-valid-investments + amount * (0.85 ^ (inv-age - 3))
      ]
    ]
    set valid_innovation_money current-valid-investments
  ]
end

;
to industrial_relocation
  ask local_governments [
    let my-place [city-name] of patch-here
    set related-companies industrial_companies with [[city-name] of patch-here = my-place and state = 1]

    if industrial_quota < 1 [
      let sorted_companies sort-on [gdp_devotion] related-companies
      let bottom_10_count ceiling ((count related-companies) * 0.1)

      if bottom_10_count != 0 [
        let bottom_10_percent_companies sublist sorted_companies 0 bottom_10_count
        let bottom_10_agentset (turtle-set bottom_10_percent_companies)

        let should-clear? false

        if real = 1 [
          set real_governments local_governments with [real = 1]
          let neighbor_governments other real_governments in-radius 10
          let removed_gdp sum [gdp_devotion] of bottom_10_agentset
          let my_gdp_after_removal (gdp - removed_gdp)
          let would-be-overtaken? false
          let neighbor_count count neighbor_governments

          if neighbor_count > 0 [
            let neighbor_gain (removed_gdp / neighbor_count)
            if any? neighbor_governments with [(gdp + neighbor_gain) > my_gdp_after_removal] [
              set would-be-overtaken? true
            ]
          ]

          if not would-be-overtaken? [
            set should-clear? true
          ]
          if neighbor_count = 0 [
            set should-clear? true
          ]
        ]

        if industrial_park = 1 [
          set should-clear? true
        ]

        if should-clear? [
          let kicked-max-gpa max [gdp_devotion / land_use] of bottom_10_agentset
          set tenglong_threshold max (list tenglong_threshold kicked-max-gpa)

          set industrial_quota industrial_quota + (sum [land_use] of bottom_10_agentset)
          set industrial_land_transfered industrial_land_transfered - (sum [land_use] of bottom_10_agentset)
          set industrial_land_transfered_total max (list 0 (industrial_land_transfered_total - (sum [land_use] of bottom_10_agentset)))
          set money money - 1000 * bottom_10_count

          ask bottom_10_agentset [
            set state 0
            set color pink
          ]
        ]
      ]
    ]
  ]
end



to industrial_relocation1
  ifelse not any? local_governments with [industrial_park = 1] [
    industrial_relocation
  ] [
    ask local_governments with [real = 1] [
    let cooperate_park one-of link-neighbors with [ industrial_park = 1 and enclave_active = 1]
  ;  show (word"cooperate_park:" cooperate_park  )
        if cooperate_park != nobody[
 ;     show (word "55555:"  [city-name1] of cooperate_park )
;        ask cooperate_park [
;        let my_place [city-name] of patch-here
;        set related_patches patches in-radius 2
;        ask related-patches [
;        ]
;         ]

        let my-place [city-name] of patch-here
;        show (my-place   )
        set related-companies industrial_companies with [ [city-name] of patch-here = my-place  and state = 1 ]
;        ask related-companies[
;;        show [city-name] of patch-here
;      ]
        let sorted_companies sort-on  [gdp_devotion ]related-companies
        let bottom_10_count ceiling ((count related-companies)  * 0.1 )
        if bottom_10_count != 0[
        let bottom_10_percent_companies sublist sorted_companies 0 bottom_10_count
        let bottom_10_agentset (turtle-set bottom_10_percent_companies)
        ; Cache released land before failed firms die and leave the agentset.
        let released-land sum [land_use] of bottom_10_agentset
        if any? bottom_10_agentset [
          let kicked-max-gpa max [gdp_devotion / land_use] of bottom_10_agentset
          set tenglong_threshold max (list tenglong_threshold kicked-max-gpa)
        ]
        ask bottom_10_agentset [
          let cooperate_park_to [cooperate_park] of myself
          let cooperate_park_to_name [city-name1 ] of cooperate_park_to
;          show (word "cooperate_park_to_name" cooperate_park_to_name)
          let move-to-patch one-of valid-patches with [city-name = cooperate_park_to_name ]
;          show (word "move-to-patch : " move-to-patch)
          if move-to-patch != nobody [
            let my-land-use [land_use] of self
            let meets-relocation-standard? true
            if scenario = 4 [
              set tax_hecture tax_devotion / land_use
              set meets-relocation-standard?
                ((standard-land-modification-factor cooperate_park_to self) * minimum_tax <= tax_hecture)
            ]

            ifelse meets-relocation-standard? [
              ifelse [industrial_quota] of cooperate_park_to  >= my-land-use[
               move-to move-to-patch
                     set target_gov cooperate_park_to
                     set state 1
                     set color blue
                ifelse [industrial_park] of target_gov = 1 [
                  let _park-host-new [enclave_host_quota_support] of target_gov
                  let _park-prov-new [enclave_provincial_quota_support] of target_gov
                  ifelse (_park-host-new + _park-prov-new) > 0 [
                    set host_quota_ratio_at_entry (_park-host-new / (_park-host-new + _park-prov-new))
                  ] [
                    set host_quota_ratio_at_entry 1
                  ]
                ] [
                  set host_quota_ratio_at_entry 0
                ]
                ask cooperate_park_to [
                  set industrial_quota  industrial_quota - my-land-use
                  let my-city-name3 [city-name3] of self
                  let park_on_government local_governments with [  city-name1 = my-city-name3 ]
                  ask park_on_government [
                    set industrial_land_transfered  ( industrial_land_transfered + my-land-use)
                    set industrial_land_transfered_total (industrial_land_transfered_total + my-land-use)
                  ]
                ]
              ]
              [
                set state 0
                set color pink
                ask myself [
                  set money money - 1000
                ]
              ]
            ]
            [
              ask myself [
                set money money - 1000
              ]
              die
            ]
         ]
        ]
      set industrial_quota industrial_quota + released-land

    ]

  ]
  ]
  ]









end


to investment_attraction

  ask patches [
    set here1  0
  ]

  ask local_governments [
;    let land_price_save ( land_money / area  )
;    set industrial_land_price_per ( land_cost + profit - land_price_save)
 ;  show (word "name" city-name1 ""word "industrial_land_price: " industrial_land_price_per)
;    set innovation_cost innovation_cost - ( valid_innovation_money) * 0.00015
;   show (word "name" city-name1"" word "innovation_cost: " innovation_cost)

    set patch-name [ city-name1 ] of self

    let patch-name1  [patch-name] of self
    ask patches with [ city-name = patch-name1]  [
  ;    show ( city-name  )
      set industrial_land_price-p [industrial_land_price_per] of myself

      set innovation_cost-p [innovation_cost] of myself
    ]
  ]




  ask industrial_companies with [state = 0] [
    set target_patch nobody
    set lowest_cost 10000000
    set lowest_cost_gov nobody
 ;  set check_state_quota 0
    set tax_hecture tax_devotion / land_use

    let cost_info []

    let company-patch-pname [city-name] of patch-here
    let here-patch patch-here

    ask here-patch [
      set here1 1
    ]

    ask valid-patches in-radius 2 [
      let current_cost (([land_preference] of myself * [land_use] of myself * [industrial_land_price-p] of self) +
                       ([innovation_preference] of myself * [innovation_cost-p] of self))

      let current_gov_name [city-name] of self
      let current_gov one-of local_governments with [city-name1 = current_gov_name]

      set cost_info lput (list current_cost self current_gov) cost_info
    ]

    set cost_info sort-by [ [a b] -> first a < first b ] cost_info

    set lowest_cost 10000000
    set second_lowest_cost 10000000
    set third_lowest_cost 10000000
    set fourth_lowest_cost 10000000
    set fifth_lowest_cost 10000000
    set sixth_lowest_cost 10000000
    set seventh_lowest_cost 10000000
    set eightth_lowest_cost 10000000
    set nineth_lowest_cost 10000000
    set tenth_lowest_cost 10000000
    set eleventh_lowest_cost 10000000
    set twelfth_lowest_cost 10000000
    set thirteenth_lowest_cost 10000000
    set fourteenth_lowest_cost 10000000

    set target_patch1-1 nobody
    set target_patch2 nobody
    set target_patch3 nobody
    set target_patch4 nobody
    set target_patch5 nobody
    set target_patch6 nobody
    set target_patch7 nobody
    set target_patch8 nobody
    set target_patch9 nobody
    set target_patch10 nobody
    set target_patch11 nobody
    set target_patch12 nobody
    set target_patch13 nobody
    set target_patch14 nobody

    set lowest_cost_gov nobody
    set second_lowest_cost_gov nobody
    set third_lowest_cost_gov nobody
    set fourth_lowest_cost_gov nobody
    set fifth_lowest_cost_gov nobody
    set sixth_lowest_cost_gov nobody
    set seventh_lowest_cost_gov nobody
    set eightth_lowest_cost_gov nobody
    set nineth_lowest_cost_gov nobody
    set tenth_lowest_cost_gov nobody
    set eleventh_lowest_cost_gov nobody
    set twelfth_lowest_cost_gov nobody
    set thirteenth_lowest_cost_gov nobody
    set fourteenth_lowest_cost_gov nobody

    if length cost_info > 0 [
      let item0 item 0 cost_info
      set lowest_cost item 0 item0
      set target_patch1-1 item 1 item0
      set lowest_cost_gov item 2 item0
    ]

    if length cost_info > 1 [
      let item1 item 1 cost_info
      set second_lowest_cost item 0 item1
      set target_patch2 item 1 item1
      set second_lowest_cost_gov item 2 item1
    ]

    if length cost_info > 2 [
      let item2 item 2 cost_info
      set third_lowest_cost item 0 item2
      set target_patch3 item 1 item2
      set third_lowest_cost_gov item 2 item2
    ]

    if length cost_info > 3 [
      let item3 item 3 cost_info
      set fourth_lowest_cost item 0 item3
      set target_patch4 item 1 item3
      set fourth_lowest_cost_gov item 2 item3
    ]

    if length cost_info > 4 [
      let item4 item 4 cost_info
      set fifth_lowest_cost item 0 item4
      set target_patch5 item 1 item4
      set fifth_lowest_cost_gov item 2 item4
    ]

    if length cost_info > 5 [
      let item5 item 5 cost_info
      set sixth_lowest_cost item 0 item5
      set target_patch6 item 1 item5
      set sixth_lowest_cost_gov item 2 item5
    ]

    if length cost_info > 6 [
      let item6 item 6 cost_info
      set seventh_lowest_cost item 0 item6
      set target_patch7 item 1 item6
      set seventh_lowest_cost_gov item 2 item6
    ]

    if length cost_info > 7 [
      let item7 item 7 cost_info
      set eightth_lowest_cost item 0 item7
      set target_patch8 item 1 item7
      set eightth_lowest_cost_gov item 2 item7
    ]

    if length cost_info > 8 [
      let item8 item 8 cost_info
      set nineth_lowest_cost item 0 item8
      set target_patch9 item 1 item8
      set nineth_lowest_cost_gov item 2 item8
    ]

    if length cost_info > 9 [
      let item9 item 9 cost_info
      set tenth_lowest_cost item 0 item9
      set target_patch10 item 1 item9
      set tenth_lowest_cost_gov item 2 item9
    ]

    if length cost_info > 10 [
      let item10 item 10 cost_info
      set eleventh_lowest_cost item 0 item10
      set target_patch11 item 1 item10
      set eleventh_lowest_cost_gov item 2 item10
    ]

    if length cost_info > 11 [
      let item11 item 11 cost_info
      set twelfth_lowest_cost item 0 item11
      set target_patch12 item 1 item11
      set twelfth_lowest_cost_gov item 2 item11
    ]

    if length cost_info > 12 [
      let item12 item 12 cost_info
      set thirteenth_lowest_cost item 0 item12
      set target_patch13 item 1 item12
      set thirteenth_lowest_cost_gov item 2 item12
    ]

    if length cost_info > 13 [
      let item13 item 13 cost_info
      set fourteenth_lowest_cost item 0 item13
      set target_patch14 item 1 item13
      set fourteenth_lowest_cost_gov item 2 item13
    ]





       ifelse lowest_cost_gov != nobody[
       ifelse target_patch1-1 != nobody[
        set target_patch target_patch1-1
        ifelse ( [industrial_quota] of lowest_cost_gov >= [land_use] of self ) and ([land_area] of lowest_cost_gov >= land_use)[
               ifelse lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1
                 ]

           ]
             [set active 2
              set  check_state_quota check_state_quota + 1
        ]
        ]

           [set active 0]
    ]
    [set active 0]

if  active = 2[
    ifelse second_lowest_cost_gov != nobody[
       ifelse target_patch2 != nobody[
        set target_patch target_patch2
        ifelse ( [industrial_quota] of second_lowest_cost_gov >= [land_use] of self ) and ([land_area] of second_lowest_cost_gov >= land_use)[
               ifelse second_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1

                 ]

           ]
             [set active 3
              set  check_state_quota check_state_quota + 1
          ]
        ]

           [set active 0]
    ]
    [set active 0]

    ]

if  active = 3[
    ifelse third_lowest_cost_gov != nobody[
       ifelse target_patch3 != nobody[
        set target_patch target_patch3
        ifelse ( [industrial_quota] of third_lowest_cost_gov >= [land_use] of self ) and ([land_area] of third_lowest_cost_gov >= land_use)[
               ifelse third_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1

                 ]

           ]
             [set active 4
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]

if  active = 4[
    ifelse fourth_lowest_cost_gov != nobody[
       ifelse target_patch4 != nobody[
        set target_patch target_patch4
        ifelse ( [industrial_quota] of fourth_lowest_cost_gov >= [land_use] of self ) and ([land_area] of fourth_lowest_cost_gov >= land_use)[
               ifelse fourth_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1

                 ]

           ]
             [set active 5
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]
if  active = 5[
    ifelse fifth_lowest_cost_gov != nobody[
       ifelse target_patch5 != nobody[
        set target_patch target_patch5
        ifelse ( [industrial_quota] of fifth_lowest_cost_gov >= [land_use] of self ) and ([land_area] of fifth_lowest_cost_gov >= land_use)[
               ifelse fifth_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1

                 ]

           ]
             [set active 6
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]

if  active = 6[
    ifelse sixth_lowest_cost_gov != nobody[
       ifelse target_patch6 != nobody[
        set target_patch target_patch6
        ifelse ( [industrial_quota] of sixth_lowest_cost_gov >= [land_use] of self ) and ([land_area] of sixth_lowest_cost_gov >= land_use)[
               ifelse sixth_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1

                 ]

           ]
             [set active 7
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]
if  active = 7[
    ifelse seventh_lowest_cost_gov != nobody[
       ifelse target_patch7 != nobody[
        set target_patch target_patch7
        ifelse ( [industrial_quota] of seventh_lowest_cost_gov >= [land_use] of self ) and ([land_area] of seventh_lowest_cost_gov >= land_use)[
               ifelse seventh_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1

                 ]

           ]
             [set active 8
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]
if  active = 8[
    ifelse eightth_lowest_cost_gov != nobody[
       ifelse target_patch8 != nobody[
        set target_patch target_patch8
        ifelse ( [industrial_quota] of eightth_lowest_cost_gov >= [land_use] of self ) and ([land_area] of eightth_lowest_cost_gov >= land_use)[
               ifelse eightth_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1

                 ]

           ]
             [set active 9
              set  check_state_quota check_state_quota + 1
           ]
        ]

           [set active 0]
    ]
    [set active 0]

    ]

if  active = 9[
    ifelse nineth_lowest_cost_gov != nobody[
       ifelse target_patch9 != nobody[
        set target_patch target_patch9
        ifelse ( [industrial_quota] of nineth_lowest_cost_gov >= [land_use] of self ) and ([land_area] of nineth_lowest_cost_gov >= land_use)[
               ifelse nineth_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1
                 ]

           ]
             [set active 10
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]
 if  active = 10[
    ifelse tenth_lowest_cost_gov != nobody[
       ifelse target_patch10 != nobody[
        set target_patch target_patch10
        ifelse ( [industrial_quota] of tenth_lowest_cost_gov >= [land_use] of self ) and ([land_area] of tenth_lowest_cost_gov >= land_use)[
               ifelse tenth_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1
                 ]

           ]
             [set active 11
             set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]
if  active = 11[
    ifelse eleventh_lowest_cost_gov != nobody[
       ifelse target_patch11 != nobody[
        set target_patch target_patch11
       ifelse ( [industrial_quota] of eleventh_lowest_cost_gov >= [land_use] of self ) and ([land_area] of eleventh_lowest_cost_gov >= land_use)[
               ifelse eleventh_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1
                 ]

           ]
             [set active 12
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]

    if  active = 12[
    ifelse twelfth_lowest_cost_gov != nobody[
       ifelse target_patch12 != nobody[
        set target_patch target_patch12
       ifelse ( [industrial_quota] of twelfth_lowest_cost_gov >= [land_use] of self ) and ([land_area] of twelfth_lowest_cost_gov >= land_use)[
               ifelse twelfth_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1
                 ]

           ]
             [set active 13
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]
   if  active = 13[
    ifelse thirteenth_lowest_cost_gov != nobody[
       ifelse target_patch13 != nobody[
        set target_patch target_patch13
       ifelse ( [industrial_quota] of thirteenth_lowest_cost_gov >= [land_use] of self ) and ([land_area] of thirteenth_lowest_cost_gov >= land_use)[
               ifelse thirteenth_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1
                 ]

           ]
             [set active 0
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]
   if  active = 14[
    ifelse fourteenth_lowest_cost_gov != nobody[
       ifelse target_patch14 != nobody[
        set target_patch target_patch14
       ifelse ( [industrial_quota] of fourteenth_lowest_cost_gov >= [land_use] of self ) and ([land_area] of fourteenth_lowest_cost_gov >= land_use)[
               ifelse fourteenth_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1
                 ]

           ]
             [set active 0
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]

   if active = 1 [
     let cand-name [city-name] of target_patch
     let cand-gov one-of local_governments with [city-name1 = cand-name]
     if cand-gov != nobody and (land_use > 0) [
       if (gdp_devotion / land_use) <= [tenglong_threshold] of cand-gov [
         set active 0
       ]
     ]
   ]

   if active = 1 [
   ;   show ( word "11111111111")
      move-to  target_patch
    ;  show (word "target_patch"  target_patch)
      let target_gov_name  [city-name] of target_patch
      set target_gov one-of local_governments with [city-name1 = target_gov_name]
      set state 1
      set color blue
      set invest-time ticks
      ifelse target_gov != nobody and [industrial_park] of target_gov = 1 [
        let _park-host-new [enclave_host_quota_support] of target_gov
        let _park-prov-new [enclave_provincial_quota_support] of target_gov
        ifelse (_park-host-new + _park-prov-new) > 0 [
          set host_quota_ratio_at_entry (_park-host-new / (_park-host-new + _park-prov-new))
        ] [
          set host_quota_ratio_at_entry 1
        ]
      ] [
        set host_quota_ratio_at_entry 0
      ]


      ask target_gov [
        ;show (word "industrial_before :" industrial_quota )
        set industrial_quota  (industrial_quota - ( [land_use] of myself ))
        set land_area ( land_area - ( [land_use] of myself ))
       ; show ( word "company_land_use"  [land_use] of myself)
        ;show (word "industrial_after :" industrial_quota )
        set money (money + industrial_land_price_per * [land_use] of myself)
        set industrial_land_transfered ( industrial_land_transfered  + ( [land_use] of myself ) )
        set industrial_land_transfered_total ( industrial_land_transfered_total + ( [land_use] of myself ) )
      ]
    ]
    if active = 0
    [
    rt random 360
      if patch-ahead 1 != nobody [
      if [pcolor] of patch-ahead 1 = white [
      forward 1
       ]
      ]
     ]





    if check_state >= 3 and (state = 0) [

      die
    ]

    if  check_state_quota >= 39 and (state = 0)[
      die
    ]

]

end



to investment_attraction_biaozhundi

  ask patches [
    set here1  0
  ]

  ask local_governments [
;    let land_price_save ( land_money / area  )
;    set industrial_land_price_per ( land_cost + profit - land_price_save)
 ;  show (word "name" city-name1 ""word "industrial_land_price: " industrial_land_price_per)
;    set innovation_cost innovation_cost - ( valid_innovation_money) * 0.00015
;   show (word "name" city-name1"" word "innovation_cost: " innovation_cost)

    set patch-name [ city-name1 ] of self

    let patch-name1  [patch-name] of self
    ask patches with [ city-name = patch-name1]  [
  ;    show ( city-name  )
      set industrial_land_price-p [ industrial_land_price_per ]   of myself

      set innovation_cost-p [innovation_cost] of myself
    ]
  ]




  ask industrial_companies with [state = 0] [
    set target_patch nobody
    set lowest_cost 10000000
    set lowest_cost_gov nobody
 ;  set check_state_quota 0
;   set  check_state_tax 0
    set tax_hecture tax_devotion / land_use

    let cost_info []

    let company-patch-pname [city-name] of patch-here
    let here-patch patch-here

    ask here-patch [
      set here1 1
    ]

    ask valid-patches in-radius 2 [
      let current_cost (([land_preference] of myself * [land_use] of myself * [industrial_land_price-p] of self) +
                       ([innovation_preference] of myself * [innovation_cost-p] of self))

      let current_gov_name [city-name] of self
      let current_gov one-of local_governments with [city-name1 = current_gov_name]

      set cost_info lput (list current_cost self current_gov) cost_info
    ]

    set cost_info sort-by [ [a b] -> first a < first b ] cost_info

    set lowest_cost 10000000
    set second_lowest_cost 10000000
    set third_lowest_cost 10000000
    set fourth_lowest_cost 10000000
    set fifth_lowest_cost 10000000
    set sixth_lowest_cost 10000000
    set seventh_lowest_cost 10000000
    set eightth_lowest_cost 10000000
    set nineth_lowest_cost 10000000
    set tenth_lowest_cost 10000000
    set eleventh_lowest_cost 10000000
    set twelfth_lowest_cost 10000000
    set thirteenth_lowest_cost 10000000
    set fourteenth_lowest_cost 10000000

    set target_patch1-1 nobody
    set target_patch2 nobody
    set target_patch3 nobody
    set target_patch4 nobody
    set target_patch5 nobody
    set target_patch6 nobody
    set target_patch7 nobody
    set target_patch8 nobody
    set target_patch9 nobody
    set target_patch10 nobody
    set target_patch11 nobody
    set target_patch12 nobody
    set target_patch13 nobody
    set target_patch14 nobody

    set lowest_cost_gov nobody
    set second_lowest_cost_gov nobody
    set third_lowest_cost_gov nobody
    set fourth_lowest_cost_gov nobody
    set fifth_lowest_cost_gov nobody
    set sixth_lowest_cost_gov nobody
    set seventh_lowest_cost_gov nobody
    set eightth_lowest_cost_gov nobody
    set nineth_lowest_cost_gov nobody
    set tenth_lowest_cost_gov nobody
    set eleventh_lowest_cost_gov nobody
    set twelfth_lowest_cost_gov nobody
    set thirteenth_lowest_cost_gov nobody
    set fourteenth_lowest_cost_gov nobody

    if length cost_info > 0 [
      let item0 item 0 cost_info
      set lowest_cost item 0 item0
      set target_patch1-1 item 1 item0
      set lowest_cost_gov item 2 item0
    ]

    if length cost_info > 1 [
      let item1 item 1 cost_info
      set second_lowest_cost item 0 item1
      set target_patch2 item 1 item1
      set second_lowest_cost_gov item 2 item1
    ]

    if length cost_info > 2 [
      let item2 item 2 cost_info
      set third_lowest_cost item 0 item2
      set target_patch3 item 1 item2
      set third_lowest_cost_gov item 2 item2
    ]

    if length cost_info > 3 [
      let item3 item 3 cost_info
      set fourth_lowest_cost item 0 item3
      set target_patch4 item 1 item3
      set fourth_lowest_cost_gov item 2 item3
    ]

    if length cost_info > 4 [
      let item4 item 4 cost_info
      set fifth_lowest_cost item 0 item4
      set target_patch5 item 1 item4
      set fifth_lowest_cost_gov item 2 item4
    ]

    if length cost_info > 5 [
      let item5 item 5 cost_info
      set sixth_lowest_cost item 0 item5
      set target_patch6 item 1 item5
      set sixth_lowest_cost_gov item 2 item5
    ]

    if length cost_info > 6 [
      let item6 item 6 cost_info
      set seventh_lowest_cost item 0 item6
      set target_patch7 item 1 item6
      set seventh_lowest_cost_gov item 2 item6
    ]

    if length cost_info > 7 [
      let item7 item 7 cost_info
      set eightth_lowest_cost item 0 item7
      set target_patch8 item 1 item7
      set eightth_lowest_cost_gov item 2 item7
    ]

    if length cost_info > 8 [
      let item8 item 8 cost_info
      set nineth_lowest_cost item 0 item8
      set target_patch9 item 1 item8
      set nineth_lowest_cost_gov item 2 item8
    ]

    if length cost_info > 9 [
      let item9 item 9 cost_info
      set tenth_lowest_cost item 0 item9
      set target_patch10 item 1 item9
      set tenth_lowest_cost_gov item 2 item9
    ]

    if length cost_info > 10 [
      let item10 item 10 cost_info
      set eleventh_lowest_cost item 0 item10
      set target_patch11 item 1 item10
      set eleventh_lowest_cost_gov item 2 item10
    ]

    if length cost_info > 11 [
      let item11 item 11 cost_info
      set twelfth_lowest_cost item 0 item11
      set target_patch12 item 1 item11
      set twelfth_lowest_cost_gov item 2 item11
    ]

    if length cost_info > 12 [
      let item12 item 12 cost_info
      set thirteenth_lowest_cost item 0 item12
      set target_patch13 item 1 item12
      set thirteenth_lowest_cost_gov item 2 item12
    ]

    if length cost_info > 13 [
      let item13 item 13 cost_info
      set fourteenth_lowest_cost item 0 item13
      set target_patch14 item 1 item13
      set fourteenth_lowest_cost_gov item 2 item13
    ]





  ifelse lowest_cost_gov != nobody[
       ifelse target_patch1-1 != nobody[
        set target_patch target_patch1-1
        ifelse ( [industrial_quota] of lowest_cost_gov >= [land_use] of self ) and ([land_area] of lowest_cost_gov >= land_use)[
          ifelse ((standard-land-modification-factor lowest_cost_gov self) * ([minimum_tax] of self ) <= ([tax_hecture] of self ) )[
               ifelse lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1
                 ]
          ]
          [
            set active 2
            set  check_state_tax check_state_tax + 1
          ]
           ]
             [set active 2
              set  check_state_quota check_state_quota + 1
        ]
        ]

           [set active 0]
    ]
    [set active 0]

if  active = 2[
    ifelse second_lowest_cost_gov != nobody[
       ifelse target_patch2 != nobody[
        set target_patch target_patch2
        ifelse ( [industrial_quota] of second_lowest_cost_gov >= [land_use] of self ) and ([land_area] of second_lowest_cost_gov >= land_use)[
            ifelse ((standard-land-modification-factor second_lowest_cost_gov self) * ([minimum_tax] of self ) <= ([tax_hecture] of self ) )[
               ifelse second_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1

                 ]
            ]
            [set active 3
             set  check_state_tax check_state_tax + 1
            ]
           ]
             [set active 3
              set  check_state_quota check_state_quota + 1
          ]
        ]

           [set active 0]
    ]
    [set active 0]

    ]

if  active = 3[
    ifelse third_lowest_cost_gov != nobody[
       ifelse target_patch3 != nobody[
        set target_patch target_patch3
        ifelse ( [industrial_quota] of third_lowest_cost_gov >= [land_use] of self ) and ([land_area] of third_lowest_cost_gov >= land_use)[
            ifelse ((standard-land-modification-factor third_lowest_cost_gov self) * ([minimum_tax] of self ) <= ([tax_hecture] of self ) )[
               ifelse third_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1

                 ]
            ]
            [set active 4
             set  check_state_tax check_state_tax + 1
            ]
           ]
             [set active 4
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]

if  active = 4[
    ifelse fourth_lowest_cost_gov != nobody[
       ifelse target_patch4 != nobody[
        set target_patch target_patch4
        ifelse ( [industrial_quota] of fourth_lowest_cost_gov >= [land_use] of self ) and ([land_area] of fourth_lowest_cost_gov >= land_use)[
            ifelse ((standard-land-modification-factor fourth_lowest_cost_gov self) * ([minimum_tax] of self ) <= ([tax_hecture] of self ) )[
               ifelse fourth_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1

                 ]
            ]
            [set active 5
              set  check_state_tax check_state_tax + 1]
           ]
             [set active 5
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]
if  active = 5[
    ifelse fifth_lowest_cost_gov != nobody[
       ifelse target_patch5 != nobody[
        set target_patch target_patch5
        ifelse ( [industrial_quota] of fifth_lowest_cost_gov >= [land_use] of self ) and ([land_area] of fifth_lowest_cost_gov >= land_use)[
             ifelse ((standard-land-modification-factor fifth_lowest_cost_gov self) * ([minimum_tax] of self ) <= ([tax_hecture] of self ) )[
               ifelse fifth_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1

                 ]
            ]
            [set active 6
              set  check_state_tax check_state_tax + 1]
           ]
             [set active 6
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]

if  active = 6[
    ifelse sixth_lowest_cost_gov != nobody[
       ifelse target_patch6 != nobody[
        set target_patch target_patch6
        ifelse ( [industrial_quota] of sixth_lowest_cost_gov >= [land_use] of self ) and ([land_area] of sixth_lowest_cost_gov >= land_use)[
             ifelse ((standard-land-modification-factor sixth_lowest_cost_gov self) * ([minimum_tax] of self ) <= ([tax_hecture] of self ) )[
               ifelse sixth_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1

                 ]
            ]
            [set active 7
              set  check_state_tax check_state_tax + 1]
           ]
             [set active 7
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]
if  active = 7[
    ifelse seventh_lowest_cost_gov != nobody[
       ifelse target_patch7 != nobody[
        set target_patch target_patch7
        ifelse ( [industrial_quota] of seventh_lowest_cost_gov >= [land_use] of self ) and ([land_area] of seventh_lowest_cost_gov >= land_use)[
            ifelse ((standard-land-modification-factor seventh_lowest_cost_gov self) * ([minimum_tax] of self ) <= ([tax_hecture] of self ) )[
               ifelse seventh_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1

                 ]
            ]
            [set active 8
              set  check_state_tax check_state_tax + 1]
           ]
             [set active 8
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]
if  active = 8[
    ifelse eightth_lowest_cost_gov != nobody[
       ifelse target_patch8 != nobody[
        set target_patch target_patch8
        ifelse ( [industrial_quota] of eightth_lowest_cost_gov >= [land_use] of self ) and ([land_area] of eightth_lowest_cost_gov >= land_use)[
            ifelse ((standard-land-modification-factor eightth_lowest_cost_gov self) * ([minimum_tax] of self ) <= ([tax_hecture] of self ) )[
               ifelse eightth_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1

                 ]
            ]
            [set active 9
              set  check_state_tax check_state_tax + 1
            ]
           ]
             [set active 9
              set  check_state_quota check_state_quota + 1
           ]
        ]

           [set active 0]
    ]
    [set active 0]

    ]

if  active = 9[
    ifelse nineth_lowest_cost_gov != nobody[
       ifelse target_patch9 != nobody[
        set target_patch target_patch9
        ifelse ( [industrial_quota] of nineth_lowest_cost_gov >= [land_use] of self ) and ([land_area] of nineth_lowest_cost_gov >= land_use)[
            ifelse ((standard-land-modification-factor nineth_lowest_cost_gov self) * ([minimum_tax] of self ) <= ([tax_hecture] of self ) )[
               ifelse nineth_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1
                 ]
            ]
            [set active 10
              set  check_state_tax check_state_tax + 1]
           ]
             [set active 10
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]
 if  active = 10[
    ifelse tenth_lowest_cost_gov != nobody[
       ifelse target_patch10 != nobody[
        set target_patch target_patch10
        ifelse ( [industrial_quota] of tenth_lowest_cost_gov >= [land_use] of self ) and ([land_area] of tenth_lowest_cost_gov >= land_use)[
            ifelse ((standard-land-modification-factor tenth_lowest_cost_gov self) * ([minimum_tax] of self ) <= ([tax_hecture] of self ) )[
               ifelse tenth_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1
                 ]
            ]
            [set active 11
             set  check_state_tax check_state_tax + 1]
           ]
             [set active 11
             set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]
if  active = 11[
    ifelse eleventh_lowest_cost_gov != nobody[
       ifelse target_patch11 != nobody[
        set target_patch target_patch11
       ifelse ( [industrial_quota] of eleventh_lowest_cost_gov >= [land_use] of self ) and ([land_area] of eleventh_lowest_cost_gov >= land_use)[
            ifelse ((standard-land-modification-factor eleventh_lowest_cost_gov self) * ([minimum_tax] of self ) <= ([tax_hecture] of self ) )[
               ifelse eleventh_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1
                 ]
            ]
            [set active 12
              set  check_state_tax check_state_tax + 1]
           ]
             [set active 12
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]

    if  active = 12[
    ifelse twelfth_lowest_cost_gov != nobody[
       ifelse target_patch12 != nobody[
        set target_patch target_patch12
       ifelse ( [industrial_quota] of twelfth_lowest_cost_gov >= [land_use] of self ) and ([land_area] of twelfth_lowest_cost_gov >= land_use)[
            ifelse ((standard-land-modification-factor twelfth_lowest_cost_gov self) * ([minimum_tax] of self ) <= ([tax_hecture] of self ) )[
               ifelse twelfth_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1
                 ]
            ]
            [set active 13
              set  check_state_tax check_state_tax + 1]
           ]
             [set active 13
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]
   if  active = 13[
    ifelse thirteenth_lowest_cost_gov != nobody[
       ifelse target_patch13 != nobody[
        set target_patch target_patch13
       ifelse ( [industrial_quota] of thirteenth_lowest_cost_gov >= [land_use] of self ) and ([land_area] of thirteenth_lowest_cost_gov >= land_use)[
              ifelse ((standard-land-modification-factor thirteenth_lowest_cost_gov self) * ([minimum_tax] of self ) <= ([tax_hecture] of self ) )[
              ifelse thirteenth_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1
                 ]
            ]
            [set active 0
              set  check_state_tax check_state_tax + 1]
           ]
             [set active 0
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]
   if  active = 14[
    ifelse fourteenth_lowest_cost_gov != nobody[
       ifelse target_patch14 != nobody[
        set target_patch target_patch14
       ifelse ( [industrial_quota] of fourteenth_lowest_cost_gov >= [land_use] of self ) and ([land_area] of fourteenth_lowest_cost_gov >= land_use)[
             ifelse ((standard-land-modification-factor fourteenth_lowest_cost_gov self) * ([minimum_tax] of self ) <= ([tax_hecture] of self ) )[
               ifelse fourteenth_lowest_cost < ([highest_preference]of self)
                [set active 1]
                [set active 0
                 set check_state check_state + 1
                 ]
            ]
            [set active 0
              set  check_state_tax check_state_tax + 1]
           ]
             [set active 0
              set  check_state_quota check_state_quota + 1]
        ]

           [set active 0]
    ]
    [set active 0]

    ]

   if active = 1 [
     let cand-name [city-name] of target_patch
     let cand-gov one-of local_governments with [city-name1 = cand-name]
     if cand-gov != nobody and (land_use > 0) [
       if (gdp_devotion / land_use) <= [tenglong_threshold] of cand-gov [
         set active 0
       ]
     ]
   ]

   if active = 1 [
   ;   show ( word "11111111111")
      move-to  target_patch
    ;  show (word "target_patch"  target_patch)
      let target_gov_name  [city-name] of target_patch
      set target_gov one-of local_governments with [city-name1 = target_gov_name]
      set state 1
      set color blue
       set invest-time ticks
      ifelse target_gov != nobody and [industrial_park] of target_gov = 1 [
        let _park-host-new [enclave_host_quota_support] of target_gov
        let _park-prov-new [enclave_provincial_quota_support] of target_gov
        ifelse (_park-host-new + _park-prov-new) > 0 [
          set host_quota_ratio_at_entry (_park-host-new / (_park-host-new + _park-prov-new))
        ] [
          set host_quota_ratio_at_entry 1
        ]
      ] [
        set host_quota_ratio_at_entry 0
      ]


      ask target_gov [
        ;show (word "industrial_before :" industrial_quota )
        set industrial_quota  (industrial_quota - ( [land_use] of myself ))
        set land_area ( land_area - ( [land_use] of myself ))
       ; show ( word "company_land_use"  [land_use] of myself)
        ;show (word "industrial_after :" industrial_quota )
        set money (money + industrial_land_price_per * [land_use] of myself)
        set industrial_land_transfered ( industrial_land_transfered  + ( [land_use] of myself ) )
        set industrial_land_transfered_total ( industrial_land_transfered_total + ( [land_use] of myself ) )
      ]
    ]
    if active = 0
    [
    rt random 360
      if patch-ahead 1 != nobody [
      if [pcolor] of patch-ahead 1 = white [
      forward 1
       ]
      ]
     ]





    if check_state >= 3 and (state = 0) [

      die
    ]

    if  check_state_quota >= 39 and (state = 0)[
      die
    ]
   if  check_state_tax >= 39 and (state = 0)[
      die
    ]
]

end



to check-company-life
  ask industrial_companies with [state = 1] [
    set age ticks - invest-time
    if age >= life [
      if target_gov != nobody [

       ask target_gov [
        ;show (word "industrial_before :" industrial_quota )
        set industrial_quota  (industrial_quota + ( [land_use] of myself ))
        set land_area ( land_area + ( [land_use] of myself ))
        set industrial_land_transfered max (list 0 (industrial_land_transfered - [land_use] of myself))
        set industrial_land_transfered_total max (list 0 (industrial_land_transfered_total - [land_use] of myself))



    ]
    die
  ]
    ]

  ]
end




to apply-competition-cut [target-government]
  ask target-government [
    if profit > 0 [
      let profit-before profit
      let profit-drop (profit-before * competition_value)
      set profit max (list 0 (profit-before - profit-drop))
      set price_minus price_minus + profit-drop

      if (scenario = 2) or (scenario = 4) [
        relax-standard-under-competition
      ]
    ]
  ]
end


to relax-standard-under-competition
  set modification_factor_resource max (list 0.9 (modification_factor_resource * (1 - competition_value)))
  set modification_factor_innovation max (list 0.9 (modification_factor_innovation * (1 - competition_value)))
end


to intergovernmental_competation
  ask local_governments [
    let my-place [city-name] of patch-here
    set related-companies industrial_companies with [ [city-name] of patch-here = my-place  and state = 1]
    set company_number count related-companies
  ]

  ask local_governments with [industrial_park = 1] [
    let company_plus company_number
    let my-city-name3 city-name3
    let my-city-name2 city-name2
    ask local_governments with [real = 1 and city-name1 = my-city-name3] [
      set company_number (company_number + company_plus * enclave-host-share myself)
    ]
    ask local_governments with [real = 1 and city-name1 = my-city-name2] [
      set company_number (company_number + company_plus * enclave-origin-share myself)
    ]
  ]

  set total_company_number sum [company_number] of local_governments with [real = 1]

  ask local_governments with [real = 1 ] [



    if company_number < ( total_company_number / 11 )[
    let lowest_land_gov min-one-of local_governments in-radius 10 [industrial_land_price_per]
    ;show (lowest_land_gov)
    let lowest_radius_profit ( [profit] of lowest_land_gov )
    if  lowest_land_gov != self [
        if lowest_radius_profit >= 0[
        set profit lowest_radius_profit
        apply-competition-cut self
        ]
      ]
    ]
  ]


  let sorted-govs1 sort-on [gdp] local_governments with [real = 1]
  let sorted-govs-reversed1 reverse sorted-govs1
  let first_gdp_government item 0 sorted-govs-reversed1
  let second_gdp_government item 1 sorted-govs-reversed1

  ask second_gdp_government [
 ; show ( word "second_gdp_government:"  second_gdp_government)
 ; show (profit)
    apply-competition-cut self
  ]

  let gdp_first_government [gdp] of first_gdp_government
  let gdp_second_government [gdp] of second_gdp_government
  if gdp_first_government > 0 [
    let gap-ratio (gdp_first_government - gdp_second_government) / gdp_first_government
    if gap-ratio < competition_threshold [
      ask first_gdp_government[
        apply-competition-cut self
      ]
    ]
  ]

  ask local_governments with [real = 1] [
    let quota-utilization ifelse-value (initial_quota_year > 0)
      [1 - (industrial_quota / initial_quota_year)] [0]
    if company_number >= (total_company_number / 11) and quota-utilization > utilization_threshold [
      let base-recovery avg_initial_profit * recovery_rate
      set profit profit + base-recovery
    ]
    if company_number < last_company_number [
      apply-competition-cut self
    ]
    set last_company_number company_number
  ]

end
;

to intergovernmental_competation1
  ask local_governments [
    let my-place [city-name] of patch-here
    set related-companies industrial_companies with [ [city-name] of patch-here = my-place and state = 1 ]
    set company_number count related-companies
  ]

  ask local_governments with [industrial_park = 1] [
    let company_plus company_number
    let my-city-name3 city-name3
    let my-city-name2 city-name2
    ask local_governments with [real = 1 and city-name1 = my-city-name3] [
      set company_number (company_number + company_plus * enclave-host-share myself)
    ]
    ask local_governments with [real = 1 and city-name1 = my-city-name2] [
      set company_number (company_number + company_plus * enclave-origin-share myself)
    ]
  ]

  set total_company_number sum [company_number] of local_governments with [real = 1]


  let sorted-govs1 sort-on [gdp] local_governments with [real = 1]
  let sorted-govs-reversed1 reverse sorted-govs1
  let first_gdp_government item 0 sorted-govs-reversed1
  let second_gdp_government item 1 sorted-govs-reversed1

  ask second_gdp_government [
 ; show ( word "second_gdp_government:"  second_gdp_government)
 ; show (profit)
    apply-competition-cut self
  ]

  let gdp_first_government [gdp] of first_gdp_government
  let gdp_second_government [gdp] of second_gdp_government
  if gdp_first_government > 0 [
    let gap-ratio (gdp_first_government - gdp_second_government) / gdp_first_government
    if gap-ratio < competition_threshold [
      ask first_gdp_government[
        apply-competition-cut self
      ]
    ]
  ]

  ask local_governments with [real = 1] [
    let quota-utilization ifelse-value (initial_quota_year > 0)
      [1 - (industrial_quota / initial_quota_year)] [0]
    if company_number >= (total_company_number / 11) and quota-utilization > utilization_threshold [
      let base-recovery avg_initial_profit * recovery_rate
      set profit profit + base-recovery
    ]
    if company_number < last_company_number [
      apply-competition-cut self
    ]
    set last_company_number company_number
  ]

end







to-report is-designated-enclave-pair? [origin-name host-name]
  report ((host-name = "Quzhou") and member? origin-name ["Hangzhou" "Shaoxing"])
      or ((host-name = "Lishui") and member? origin-name ["Ningbo" "Huzhou" "Jiaxing"])
end




to ensure-designated-enclave-parks
  ensure-enclave-pair "Hangzhou" "Quzhou"
  ensure-enclave-pair "Shaoxing" "Quzhou"
  ensure-enclave-pair "Ningbo" "Lishui"
  ensure-enclave-pair "Huzhou" "Lishui"
  ensure-enclave-pair "Jiaxing" "Lishui"
end




to ensure-enclave-pair [origin-name host-name]
  let origin-government one-of local_governments with [real = 1 and city-name1 = origin-name]
  let host-government one-of local_governments with [real = 1 and city-name1 = host-name]

  if (origin-government != nobody) and (host-government != nobody) [
    if not any? local_governments with [industrial_park = 1 and enclave_active = 1 and city-name2 = origin-name and city-name3 = host-name] [
      create-enclave-park origin-government host-government
    ]
  ]
end


to ensure-full-designated-enclave-parks
  ensure-enclave-pair "Hangzhou" "Quzhou"
  ensure-enclave-pair "Shaoxing" "Quzhou"
  ensure-enclave-pair "Ningbo" "Lishui"
  ensure-enclave-pair "Huzhou" "Lishui"
  ensure-enclave-pair "Jiaxing" "Lishui"
  ensure-enclave-pair "Wenzhou" "Jinhua"
  ensure-enclave-pair "Taizhou" "Zhoushan"
end

to endogenous-cooperation-formation
  if ticks < 5 [ stop ]
  let enclave-minimum-quota 1.60
  let median-companies median [company_number] of real_governments

  ask real_governments [
    set want_host 0
    if company_number < (total_company_number / 11) and industrial_quota >= enclave-minimum-quota [
      let my-name city-name1
      if not any? local_governments with [industrial_park = 1 and enclave_active = 1 and city-name3 = my-name] [
        set want_host 1
      ]
    ]
  ]

  ask real_governments [
    if industrial_quota < enclave-minimum-quota and company_number > median-companies [
      let my-name city-name1
      if not any? local_governments with [industrial_park = 1 and enclave_active = 1 and city-name2 = my-name] [
        let candidate one-of other real_governments in-radius 10 with [want_host = 1]
        if candidate != nobody [
          create-enclave-park self candidate
          ask candidate [ set want_host 0 ]
        ]
      ]
    ]
  ]
end

to endogenous-cooperation-formation-for-free-cities
  if ticks < 5 [ stop ]
  let enclave-minimum-quota 1.60
  let free-cities ["Jinhua" "Taizhou" "Wenzhou" "Zhoushan"]
  let median-companies median [company_number] of real_governments

  ask real_governments [
    set want_host 0
    if member? city-name1 free-cities [
      if company_number < (total_company_number / 11) and industrial_quota >= enclave-minimum-quota [
        let my-name city-name1
        if not any? local_governments with [industrial_park = 1 and enclave_active = 1 and city-name3 = my-name] [
          set want_host 1
        ]
      ]
    ]
  ]

  ask real_governments [
    if member? city-name1 free-cities [
      if industrial_quota < enclave-minimum-quota and company_number > median-companies [
        let my-name city-name1
        if not any? local_governments with [industrial_park = 1 and enclave_active = 1 and city-name2 = my-name] [
          let candidate one-of other real_governments in-radius 10 with [want_host = 1]
          if candidate != nobody [
            create-enclave-park self candidate
            ask candidate [ set want_host 0 ]
          ]
        ]
      ]
    ]
  ]
end


to create-enclave-park [origin-government host-government]
  ask host-government [
    let origin-government-name [city-name1] of origin-government
    let host-government-name city-name1
    let existing-parks local_governments with [industrial_park = 1 and city-name2 = origin-government-name and city-name3 = host-government-name]
    let park-index (count existing-parks) + 1

    let base-tc-rate 0.10
    let past-parks local_governments with [industrial_park = 1 and enclave_active = 0 and city-name2 = origin-government-name and city-name3 = host-government-name]
    let active-parks local_governments with [industrial_park = 1 and enclave_active = 1 and city-name2 = origin-government-name and city-name3 = host-government-name]
    let tc-rate base-tc-rate
    if any? past-parks [
      set tc-rate base-tc-rate * 1.5
    ]
    if any? active-parks [
      set tc-rate base-tc-rate * 0.5
    ]

    hatch 1 [
      set industrial_park_positive 1
      set industrial_park_quota 0
      set industrial_quota 0
      set GDP 0
      set money 0
      set real 0
      set industrial_park 1
      set industrial_land_transfered 0
      set industrial_land_transfered_total 0
      set city-name2 origin-government-name
      set city-name3 host-government-name
      set city-name1 (word city-name3 "_" city-name2 "_" park-index)
      set enclave_active 1
      set cooperation_years 0
      set transaction_cost_rate tc-rate
      set enclave_origin_opportunity_3y 0
      set enclave_host_opportunity_3y 0
      set enclave_origin_benefit_3y 0
      set enclave_host_benefit_3y 0
      set enclave_expansion_round park-index
      set enclave_host_share 0.6
      set enclave_provincial_quota_support 0
      set enclave_host_quota_support 0
      set enclave_age 0
      rt random 360
      fd 2
      create-link-with origin-government
      ask my-links [ set color black ]
      let turtle-city-name city-name1
      let nearby_park_patches valid-patches in-radius 2
      ifelse any? nearby_park_patches [
        ask nearby_park_patches [
          set city-name turtle-city-name
          set pcolor green
        ]
      ] [
        ask my-links [ die ]
        die
      ]
    ]
  ]
end




to-report estimate-origin-self-use-benefit [origin-government money-contribution]
  let local-land-price max (list 1 ([industrial_land_price_per] of origin-government))
  let equivalent-land (money-contribution / local-land-price)
  let local-return-per-hectare max (list 0 (([gdp_per] of origin-government) + ([industrial_land_price_per] of origin-government)))
  report equivalent-land * local-return-per-hectare
end




to-report estimate-host-self-use-benefit [host-government quota-contribution]
  let local-return-per-hectare max (list 0 (([gdp_per] of host-government) + ([industrial_land_price_per] of host-government)))
  report quota-contribution * local-return-per-hectare
end




to deactivate-enclave-park
  let park-name city-name1
  let host-government-name city-name3
  let host-government one-of local_governments with [real = 1 and city-name1 = host-government-name]

  ask industrial_companies with [target_gov = myself] [
    if host-government != nobody [
      set target_gov host-government
    ]
  ]

  if host-government != nobody [
    ask patches with [city-name = park-name] [
      set city-name host-government-name
      set pcolor white
    ]
  ]

  ask my-links [ die ]
  set enclave_active 0
  set cooperate 0
  set industrial_park_quota 0
  set industrial_quota 0
  set gdp 0
  set money 0
  set enclave_provincial_quota_support 0
  set enclave_host_quota_support 0
  set enclave_host_share 0.6
  set enclave_age 0
end




to intergovernmental_cooperation
  if enclave_type = 1 [ endogenous-cooperation-formation ]
  if enclave_type = 2 [
    ensure-designated-enclave-parks
    endogenous-cooperation-formation-for-free-cities
  ]
  if enclave_type = 3 [ ensure-full-designated-enclave-parks ]

  let active-enclave-parks local_governments with [industrial_park = 1 and enclave_active = 1]
  let enclave-minimum-quota 1.60
  let provincial-enclave-quota-pool (total_industrial_land_quota_year * 0.10)
  let provincial-reward-per-park 0

  if any? active-enclave-parks [
    set provincial-reward-per-park (provincial-enclave-quota-pool / count active-enclave-parks)
  ]

  ask active-enclave-parks [
    let origin-government one-of local_governments with [real = 1 and city-name1 = [city-name2] of myself]
    let host-government one-of local_governments with [real = 1 and city-name1 = [city-name3] of myself]

    set enclave_provincial_quota_support provincial-reward-per-park
    set enclave_host_quota_support 0
    set industrial_quota industrial_quota + provincial-reward-per-park

    if (origin-government != nobody) and (host-government != nobody) [

      let host-mandatory max (list 0 ([industrial_quota] of host-government * 0.2))
      ask host-government [
        set industrial_quota max (list 0 (industrial_quota - host-mandatory))
        set cooperate 1
        set industrial_park_quota 1
      ]
      set industrial_quota industrial_quota + host-mandatory
      let total-host-contribution host-mandatory

      if industrial_quota < enclave-minimum-quota [
        let needed (enclave-minimum-quota - industrial_quota)
        let available [industrial_quota] of host-government
        let host-topup min (list needed available)
        if host-topup > 0 [
          ask host-government [
            set industrial_quota max (list 0 (industrial_quota - host-topup))
          ]
          set industrial_quota industrial_quota + host-topup
          set total-host-contribution total-host-contribution + host-topup
        ]
      ]

      set enclave_host_quota_support total-host-contribution
      ifelse industrial_quota > 0 [
        set enclave_host_share max (list 0.6 (min (list 0.7 (total-host-contribution / industrial_quota))))
      ] [
        set enclave_host_share 0.65
      ]

      let money-rate ifelse-value (enclave_age = 0) [0.10] [0.01]
      let annual-money-contribution max (list 0 ([money] of origin-government * money-rate))
      ask origin-government [
        set money max (list 0 (money - annual-money-contribution))
        set cooperate 1
      ]
      set money money + annual-money-contribution

      let opportunity-cost-base ifelse-value (enclave_age = 0) [0] [annual-money-contribution]
      set enclave_origin_opportunity_3y enclave_origin_opportunity_3y + estimate-origin-self-use-benefit origin-government opportunity-cost-base
      set enclave_host_opportunity_3y enclave_host_opportunity_3y + estimate-host-self-use-benefit host-government total-host-contribution
    ]
  ]
end

to cooperation_change
  let pairs-to-expand []
  ask local_governments with [industrial_park = 1 and enclave_active = 1][
    let park-tax sum [tax_devotion] of industrial_companies with [state = 1 and target_gov = self]
    let park-annual-output (gdp + park-tax)

    let annual-transaction-cost (park-tax * transaction_cost_rate)
    let origin-tc-share (annual-transaction-cost * enclave-origin-share self)
    let host-tc-share (annual-transaction-cost * enclave-host-share self)
    let origin-government one-of local_governments with [real = 1 and city-name1 = [city-name2] of myself]
    let host-government one-of local_governments with [real = 1 and city-name1 = [city-name3] of myself]
    if origin-government != nobody [
      ask origin-government [ set money money - origin-tc-share ]
    ]
    if host-government != nobody [
      ask host-government [ set money money - host-tc-share ]
    ]

    let origin-annual-benefit (park-annual-output * enclave-origin-share self) - origin-tc-share
    let host-annual-benefit (park-annual-output * enclave-host-share self) - host-tc-share
    set enclave_origin_benefit_3y enclave_origin_benefit_3y + origin-annual-benefit
    set enclave_host_benefit_3y enclave_host_benefit_3y + host-annual-benefit
    set cooperation_years cooperation_years + 1
    set enclave_age enclave_age + 1

    if cooperation_years >= 3 [
      let origin-net-benefit (enclave_origin_benefit_3y - enclave_origin_opportunity_3y)
      let host-net-benefit (enclave_host_benefit_3y - enclave_host_opportunity_3y)
      let should-exit? ((origin-net-benefit < 0) or (host-net-benefit < 0))
      let should-expand? ((enclave_origin_opportunity_3y > 0) and (enclave_host_opportunity_3y > 0) and
        (origin-net-benefit >= (1.5 * enclave_origin_opportunity_3y)) and
        (host-net-benefit >= (1.5 * enclave_host_opportunity_3y)))

      if should-expand? [
        let my-origin-name city-name2
        let my-host-name city-name3
        let current-pair-active-parks count local_governments with [
          industrial_park = 1 and enclave_active = 1 and
          city-name2 = my-origin-name and city-name3 = my-host-name
        ]
        if current-pair-active-parks < 3 [
          set pairs-to-expand lput (list my-origin-name my-host-name) pairs-to-expand
        ]
      ]

      if should-exit? [
        deactivate-enclave-park
      ]

      set cooperation_years 0
      set enclave_origin_opportunity_3y 0
      set enclave_host_opportunity_3y 0
      set enclave_origin_benefit_3y 0
      set enclave_host_benefit_3y 0
    ]
  ]

  foreach pairs-to-expand [ pair ->
    let expand-origin-name item 0 pair
    let expand-host-name item 1 pair
    let expand-origin one-of local_governments with [real = 1 and city-name1 = expand-origin-name]
    let expand-host one-of local_governments with [real = 1 and city-name1 = expand-host-name]
    if (expand-origin != nobody) and (expand-host != nobody) [
      create-enclave-park expand-origin expand-host
    ]
  ]
end









to external_control
ask local_governments[
  if industrial_land_price_per < lowest_price_control [
     set  industrial_land_price_per lowest_price_control

    ]

  ]

end



to investment_growth_hatch
  ask industrial_companies with [state = 1][
    let here-patch patch-here
    let here-name [city-name] of here-patch
    let here_governments local_governments with [city-name1 = here-name ]
    set here_governments one-of here_governments
    if  here_governments != nobody [
    let total_cost_here ( ( [industrial_land_price_per] of here_governments ) * ([land_use ] of self ) * ([land_preference] of self)  ) +  ( ( [ innovation_cost ] of here_governments ) * ([innovation_preference] of self))
   ; show (word "industrial_land_price_per"    [industrial_land_price_per] of here_governments)
   ;   show (word "innovation_cost" [ innovation_cost ] of here_governments  )
    ;  show (word "total_cost_here" total_cost_here)
    ;  set total_cost_here mean [total_cost] of here_governments
      let highest_preference_self [highest_preference] of self

      if total_cost_here < highest_preference_self [
        let growth_proportion (highest_preference_self - total_cost_here) / highest_preference_self
       ; show (growth_proportion )
        set growth_proportion growth_proportion * hatch_proportion
        ;let growth_demand ceiling (growth_proportion * count industrial_companies-here)
        if random-float 1 < growth_proportion[
           hatch 1 [
              set shape "car"
              set state 0
              set color green
              set new_hatch 1
           ]
        ]
      ]
    ]
  ]
end



to update-lorenz-plot1
  clear-plot
  set-current-plot-pen "equal"
  plot 0
  plot 1

  set-current-plot-pen "dominant"

  plot-pen-down
  plotxy 0 0
  plotxy 1 0
  plotxy 1 1
  plot-pen-up

  set-current-plot-pen "lorenz"
  set-plot-pen-interval 1 / 11
  plot 0

  ask local_governments with [ real = 1]  [
    let my-city-name1 [city-name1] of self
;    let patch_area count patches with [ city-name = my-city-name1]
;    set GDP_per  ([GDP] of self )  / patch_area

  ]

  let sorted-wealths sort [GDP] of local_governments with [real = 1]
  let total-wealth sum sorted-wealths
  if total-wealth > 0 [
    let wealth-sum-so-far 0
    let index 0

    repeat 11 [
      set wealth-sum-so-far (wealth-sum-so-far + item index sorted-wealths)
      plot (wealth-sum-so-far / total-wealth)
      set index (index + 1)
    ]
  ]
end

to-report gini-gdp
  let xs sort [GDP] of local_governments with [real = 1]
  let n length xs
  let sumx sum xs
  if sumx = 0 [ report 0 ]

  let i 0
  let cum 0
  foreach xs [
    x ->
    set i i + 1
    set cum cum + (i * x)
  ]

  report (2 * cum) / (n * sumx) - (n + 1) / n
end

to-report current-output-run-number
  if run-number > 0 [
    report run-number
  ]

  let detected-run 1
  carefully [
    set detected-run behaviorspace-run-number
  ] [
    ; Outside BehaviorSpace, fall back to 1.
  ]
  report detected-run
end

to-report current-output-experiment-name
  let detected-name "manual"
  carefully [
    set detected-name behaviorspace-experiment-name
  ] [
    ; Outside BehaviorSpace, fall back to a stable manual label.
  ]
  report detected-name
end

to initialize-output-file [filename header-line]
  let current-run current-output-run-number

  if (ticks = 0) and (current-run = 1) and file-exists? filename [
    file-delete filename
  ]

  if not file-exists? filename [
    file-open filename
    file-print header-line
    file-close
  ]
end

to save_file1
  let filename (word current-output-experiment-name "_turtle_data_s" scenario "_e" enclave_type "_feijiazhiguan.csv")
  let current-run current-output-run-number
  initialize-output-file
    filename
    "scenario,quota_scale,biaozhun,share_proportion,run-number,seed_value,tick,unit_type,local_governments_id,local_governments_name,park_from_name,park_to_name,industrial_land_price_per,GDP,area_patches,gdp_per,count_companies,industrial_land_transfered,industrial_land_transfered_total,innovation_money_over_land_money,gdp_companies,mean_minimum_tax,median_minimum_tax,sd_minimum_tax,mean_tax_hecture,median_tax_hecture,sd_tax_hecture,share_meeting_standard,avg_innovation_preference,mean_new_company_gdp,mean_new_company_minimum_tax,share_new_tech_companies,share_new_resource_companies,local_gdp_hecture,local_land_use,host_park_land_share,enclave_active,transaction_cost_rate,modification_factor_innovation,modification_factor_resource,model1,model2,model3,model4"

  file-open filename

  ask local_governments with [real = 1 or industrial_park = 1] [
    if company_number != 0 [
      set gdp_companies gdp / company_number
    ]

    let land_innovation_ratio 0
    if land_money != 0 [
      set land_innovation_ratio innovation_money / land_money
    ]

    let active-local-companies industrial_companies with [state = 1 and target_gov = myself]
    let local-company-total count active-local-companies
    let local-mean-minimum-tax 0
    let local-median-minimum-tax 0
    let local-sd-minimum-tax 0
    let local-mean-tax-hecture 0
    let local-median-tax-hecture 0
    let local-sd-tax-hecture 0
    let local-share-meeting-standard 0
    let local-avg-innovation-preference 0
    let new-local-companies industrial_companies with [state = 1 and target_gov = myself and invest-time = ticks]
    let new-company-total count new-local-companies
    let local-mean-new-company-gdp 0
    let local-mean-new-company-minimum-tax 0
    let local-share-new-tech-companies 0
    let local-share-new-resource-companies 0
    let local-gdp-hecture 0
    let local-land-use 0
    let host-park-land-share 0

    if local-company-total != 0 [
      set local-mean-minimum-tax mean [minimum_tax] of active-local-companies
      set local-median-minimum-tax median [minimum_tax] of active-local-companies
      if local-company-total > 1 [
        set local-sd-minimum-tax standard-deviation [minimum_tax] of active-local-companies
      ]
      set local-mean-tax-hecture mean [tax_hecture] of active-local-companies
      set local-median-tax-hecture median [tax_hecture] of active-local-companies
      if local-company-total > 1 [
        set local-sd-tax-hecture standard-deviation [tax_hecture] of active-local-companies
      ]
      set local-share-meeting-standard
        (count active-local-companies with [((standard-land-modification-factor myself self) * minimum_tax) <= tax_hecture]) / local-company-total
      set local-avg-innovation-preference mean [innovation_preference] of active-local-companies
      set local-land-use sum [land_use] of active-local-companies
    ]

    if new-company-total != 0 [
      set local-mean-new-company-gdp mean [gdp_devotion] of new-local-companies
      set local-mean-new-company-minimum-tax mean [minimum_tax] of new-local-companies
      set local-share-new-tech-companies (count new-local-companies with [type1 = 1]) / new-company-total
      set local-share-new-resource-companies (count new-local-companies with [type1 = 0]) / new-company-total
    ]

    if real = 1 [
      let my-name city-name1
      let hosted-parks local_governments with [industrial_park = 1 and enclave_active = 1 and city-name3 = my-name]
      if any? hosted-parks [
        set host-park-land-share
          sum [sum [land_use * host_quota_ratio_at_entry] of industrial_companies with [state = 1 and target_gov = myself]] of hosted-parks
      ]
    ]
    let total-land-invested (local-land-use + host-park-land-share)
    if total-land-invested > 0 [
      set local-gdp-hecture gdp / total-land-invested
    ]

    let unit-type "government"
    let park-from-name ""
    let park-to-name ""
    if industrial_park = 1 [
      set unit-type "industrial_park"
      set park-from-name city-name3
      set park-to-name city-name2
    ]

    file-print (word
      scenario "," quota-scale "," biaozhun "," share_proportion "," current-run "," seed_value "," ticks "," unit-type "," who "," city-name1 ","
      park-from-name "," park-to-name ","
      industrial_land_price_per "," GDP "," area_patches "," gdp_per ","
      company_number "," industrial_land_transfered "," industrial_land_transfered_total "," land_innovation_ratio ","
      gdp_companies "," local-mean-minimum-tax "," local-median-minimum-tax ","
      local-sd-minimum-tax "," local-mean-tax-hecture "," local-median-tax-hecture ","
      local-sd-tax-hecture "," local-share-meeting-standard ","
      local-avg-innovation-preference "," local-mean-new-company-gdp ","
      local-mean-new-company-minimum-tax "," local-share-new-tech-companies ","
      local-share-new-resource-companies ","
      local-gdp-hecture "," local-land-use "," host-park-land-share ","
      enclave_active "," transaction_cost_rate "," modification_factor_innovation "," modification_factor_resource ","
      model1 "," model2 "," model3 "," model4
    )
  ]

  file-close
end
@#$#@#$#@
GRAPHICS-WINDOW
298
24
680
407
-1
-1
11.33333333333334
1
10
1
1
1
0
0
0
1
-16
16
-16
16
1
1
1
ticks
30.0

BUTTON
38
53
104
86
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
40
95
103
128
NIL
go1
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
38
189
210
222
value-influence
value-influence
0
1
0.1
0.02
1
NIL
HORIZONTAL

PLOT
864
231
1024
351
companies number
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count industrial_companies with [state = 1]"

PLOT
712
13
982
228
land price plot
time
industrial_land_price
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Hangzhou" 1.0 0 -10873583 true "" "plot [industrial_land_price_per ] of local_government 0"
"Huzhou" 1.0 0 -7171555 true "" "plot [industrial_land_price_per ] of local_government 1"
"Jiaxing" 1.0 0 -15040220 true "" "plot [industrial_land_price_per ] of local_government 2"
"Jinhua" 1.0 0 -13345367 true "" "plot [industrial_land_price_per ] of local_government 3"
"Lishui" 1.0 0 -7500403 true "" "plot [industrial_land_price_per ] of local_government 4"
"Ningbo" 1.0 0 -2674135 true "" "plot [industrial_land_price_per ] of local_government 5"
"Quzhou" 1.0 0 -955883 true "" "plot [industrial_land_price_per ] of local_government 6"
"Shaoxing" 1.0 0 -6459832 true "" "plot [industrial_land_price_per ] of local_government 7"
"Taizhou" 1.0 0 -1184463 true "" "plot [industrial_land_price_per ] of local_government 8"
"Wenzhou" 1.0 0 -10899396 true "" "plot [industrial_land_price_per ] of local_government 9"
"Zhoushan" 1.0 0 -13840069 true "" "plot [industrial_land_price_per ] of local_government 10"

PLOT
698
231
858
351
value_change
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if [land_money] of local_government 0 > 0 [plot ([innovation_money] of local_government 0) / ([land_money] of local_government 0)]"
"pen-1" 1.0 0 -7500403 true "" "if [land_money] of local_government 1 > 0 [plot ([innovation_money] of local_government 1) / ([land_money] of local_government 1)]"
"pen-2" 1.0 0 -2674135 true "" "if [land_money] of local_government 2 > 0 [plot ([innovation_money] of local_government 2) / ([land_money] of local_government 2)]"
"pen-3" 1.0 0 -955883 true "" "if [land_money] of local_government 3 > 0 [plot ([innovation_money] of local_government 3) / ([land_money] of local_government 3)]"
"pen-4" 1.0 0 -6459832 true "" "if [land_money] of local_government 4 > 0 [plot ([innovation_money] of local_government 4) / ([land_money] of local_government 4)]"
"pen-5" 1.0 0 -1184463 true "" "if [land_money] of local_government 5 > 0 [plot ([innovation_money] of local_government 5) / ([land_money] of local_government 5)]"
"pen-6" 1.0 0 -10899396 true "" "if [land_money] of local_government 6 > 0 [plot ([innovation_money] of local_government 6) / ([land_money] of local_government 6)]"
"pen-7" 1.0 0 -13840069 true "" "if [land_money] of local_government 7 > 0 [plot ([innovation_money] of local_government 7) / ([land_money] of local_government 7)]"
"pen-8" 1.0 0 -14835848 true "" "if [land_money] of local_government 8 > 0 [plot ([innovation_money] of local_government 8) / ([land_money] of local_government 8)]"
"pen-9" 1.0 0 -11221820 true "" "if [land_money] of local_government 9 > 0 [plot ([innovation_money] of local_government 9) / ([land_money] of local_government 9)]"
"pen-10" 1.0 0 -13791810 true "" "if [land_money] of local_government 10 > 0 [plot ([innovation_money] of local_government 10) / ([land_money] of local_government 10)]"

BUTTON
108
94
171
127
NIL
go2
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
37
233
218
266
creation_proportion
creation_proportion
0
1
0.0
0.0001
1
NIL
HORIZONTAL

SLIDER
37
278
209
311
hatch_proportion
hatch_proportion
0
1
1.0E-4
0.0001
1
NIL
HORIZONTAL

PLOT
701
371
901
521
industrial_park
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count ( local_governments with [ industrial_park = 1] )"

SLIDER
37
374
209
407
share_proportion
share_proportion
0
1
0.5
0.1
1
NIL
HORIZONTAL

PLOT
912
369
1112
519
local_governments
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count local_governments"

BUTTON
41
141
104
174
NIL
go3
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
39
423
211
456
competition_value
competition_value
0
0.5
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
39
466
211
499
recovery_rate
recovery_rate
0
0.2
0.05
0.01
1
NIL
HORIZONTAL

SLIDER
39
509
211
542
competition_threshold
competition_threshold
0
0.3
0.1
0.1
1
NIL
HORIZONTAL

SLIDER
39
552
211
585
utilization_threshold
utilization_threshold
0
1
0.7
0.1
1
NIL
HORIZONTAL

PLOT
1003
16
1251
224
GDP_per plot
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Hangzhou" 1.0 0 -10873583 true "" "plot (( [GDP] of local_government 0 ) / (count patches with [ city-name = [city-name1] of  local_government 0 ]))"
"Huzhou" 1.0 0 -7171555 true "" "plot (( [GDP] of local_government 1) / (count patches with [ city-name = [city-name1] of  local_government 1 ]))"
"Jiaxing" 1.0 0 -15040220 true "" "plot (( [GDP] of local_government 2) / (count patches with [ city-name = [city-name1] of  local_government 2 ]))"
"Jinhua" 1.0 0 -13345367 true "" "plot (( [GDP] of local_government 3) / (count patches with [ city-name = [city-name1] of  local_government 3 ]))"
"Lishui" 1.0 0 -7500403 true "" "plot (( [GDP] of local_government 4) / (count patches with [ city-name = [city-name1] of  local_government 4 ]))"
"Ningbo" 1.0 0 -2674135 true "" "plot (( [GDP] of local_government 5) / (count patches with [ city-name = [city-name1] of  local_government 5 ]))"
"Quzhou" 1.0 0 -955883 true "" "plot (( [GDP] of local_government 6) / (count patches with [ city-name = [city-name1] of  local_government 6 ]))"
"Shaoxing" 1.0 0 -6459832 true "" "plot (( [GDP] of local_government 7) / (count patches with [ city-name = [city-name1] of  local_government 7 ]))"
"Taizhou" 1.0 0 -1184463 true "" "plot (( [GDP] of local_government 8) / (count patches with [ city-name = [city-name1] of  local_government 8 ]))"
"Wenzhou" 1.0 0 -10899396 true "" "plot (( [GDP] of local_government 9) / (count patches with [ city-name = [city-name1] of  local_government 9 ]))"
"Zhoushan" 1.0 0 -13840069 true "" "plot (( [GDP] of local_government 10) / (count patches with [ city-name = [city-name1] of  local_government 10 ]))"

SLIDER
40
473
212
506
hyber_link_count
hyber_link_count
0
11
10.0
1
1
NIL
HORIZONTAL

PLOT
1278
17
1479
163
GDP_PER  Lorenz curve
NIL
NIL
0.0
1.0
0.0
1.0
true
true
"" "update-lorenz-plot1"
PENS
"lorenz" 1.0 0 -16777216 true "" ""
"equal" 1.0 0 -2674135 true "" ""
"dominant" 1.0 0 -13345367 true "" ""

PLOT
1127
258
1417
516
GDP plot
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Hangzhou" 1.0 0 -10873583 true "" "plot ( [GDP] of local_government 0 ) "
"Huzhou" 1.0 0 -7171555 true "" "plot ( [GDP] of local_government 1 ) "
"Jiaxing" 1.0 0 -15040220 true "" "plot ( [GDP] of local_government 2 ) "
"Jinhua" 1.0 0 -13345367 true "" "plot ( [GDP] of local_government 3 ) "
"Lishui" 1.0 0 -7500403 true "" "plot ( [GDP] of local_government 4 ) "
"Ningbo" 1.0 0 -2674135 true "" "plot ( [GDP] of local_government 5 ) "
"Quzhou" 1.0 0 -955883 true "" "plot ( [GDP] of local_government 6 ) "
"Shaoxing" 1.0 0 -6459832 true "" "plot ( [GDP] of local_government 7 ) "
"Taizhou" 1.0 0 -1184463 true "" "plot ( [GDP] of local_government 8 ) "
"Wenzhou" 1.0 0 -10899396 true "" "plot ( [GDP] of local_government 9 ) "
"Zhoushan" 1.0 0 -13840069 true "" "plot ( [GDP] of local_government 10 ) "

PLOT
1439
188
1639
338
 gdp lorenz plot
NIL
NIL
0.0
1.0
0.0
1.0
true
true
"" "update-lorenz-plot1"
PENS
"lorenz" 1.0 0 -16777216 true "" ""
"equal" 1.0 0 -7500403 true "" ""
"dominant" 1.0 0 -2674135 true "" ""

BUTTON
116
141
218
175
NIL
setup-runs
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
108
54
171
87
NIL
go4
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
190
56
253
89
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
40
326
212
359
scenario
scenario
1
4
1.0
1
1
NIL
HORIZONTAL

SLIDER
235
462
407
495
quota-scale
quota-scale
0.8
5
1.0
0.1
1
NIL
HORIZONTAL

BUTTON
174
94
295
127
NIL
go-withdrawal
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
437
465
609
498
biaozhun
biaozhun
0.4
2
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
635
465
807
498
seed_value
seed_value
1
50
1.0
1
1
NIL
HORIZONTAL

SLIDER
635
510
807
543
enclave_type
enclave_type
0
3
0.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="4scenario" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 80</exitCondition>
    <enumeratedValueSet variable="creation_proportion">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competition_value">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="value-influence">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold">
      <value value="0.7"/>
    </enumeratedValueSet>
      <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
      <value value="31"/>
      <value value="32"/>
      <value value="33"/>
      <value value="34"/>
      <value value="35"/>
      <value value="36"/>
      <value value="37"/>
      <value value="38"/>
      <value value="39"/>
      <value value="40"/>
      <value value="41"/>
      <value value="42"/>
      <value value="43"/>
      <value value="44"/>
      <value value="45"/>
      <value value="46"/>
      <value value="47"/>
      <value value="48"/>
      <value value="49"/>
      <value value="50"/>
    </enumeratedValueSet>
</experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go-withdrawal</go>
    <exitCondition>ticks &gt;= 80</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="biaozhun">
      <value value="0.4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="creation_proportion">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competition_value">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="value-influence">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale">
      <value value="1"/>
    </enumeratedValueSet>
      <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
      <value value="31"/>
      <value value="32"/>
      <value value="33"/>
      <value value="34"/>
      <value value="35"/>
      <value value="36"/>
      <value value="37"/>
      <value value="38"/>
      <value value="39"/>
      <value value="40"/>
      <value value="41"/>
      <value value="42"/>
      <value value="43"/>
      <value value="44"/>
      <value value="45"/>
      <value value="46"/>
      <value value="47"/>
      <value value="48"/>
      <value value="49"/>
      <value value="50"/>
    </enumeratedValueSet>
</experiment>
  <experiment name="quota_robustness" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 80</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competition_value">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="value-influence">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale">
      <value value="0.8"/>
      <value value="1"/>
      <value value="1.2"/>
      <value value="1.5"/>
      <value value="2"/>
      <value value="3"/>
      <value value="5"/>
    </enumeratedValueSet>
      <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
    </enumeratedValueSet>
</experiment>
  <experiment name="biaozhun" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 80</exitCondition>
    <enumeratedValueSet variable="quota-scale">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="biaozhun">
      <value value="0.4"/>
      <value value="0.6"/>
      <value value="0.8"/>
      <value value="1"/>
      <value value="1.5"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competition_value">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="creation_proportion">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="value-influence">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
      <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
    </enumeratedValueSet>
</experiment>
  <experiment name="share_proportion" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 80</exitCondition>
    <enumeratedValueSet variable="quota-scale">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="biaozhun">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competition_value">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="creation_proportion">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion">
      <value value="0.2"/>
      <value value="0.5"/>
      <value value="0.8"/>
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="value-influence">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
      <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
    </enumeratedValueSet>
</experiment>
  <experiment name="8scenario_baseline" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 80</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competition_value">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="value-influence">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
      <value value="31"/>
      <value value="32"/>
      <value value="33"/>
      <value value="34"/>
      <value value="35"/>
      <value value="36"/>
      <value value="37"/>
      <value value="38"/>
      <value value="39"/>
      <value value="40"/>
      <value value="41"/>
      <value value="42"/>
      <value value="43"/>
      <value value="44"/>
      <value value="45"/>
      <value value="46"/>
      <value value="47"/>
      <value value="48"/>
      <value value="49"/>
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="8scenario_enclave" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 80</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competition_value">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="value-influence">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
      <value value="31"/>
      <value value="32"/>
      <value value="33"/>
      <value value="34"/>
      <value value="35"/>
      <value value="36"/>
      <value value="37"/>
      <value value="38"/>
      <value value="39"/>
      <value value="40"/>
      <value value="41"/>
      <value value="42"/>
      <value value="43"/>
      <value value="44"/>
      <value value="45"/>
      <value value="46"/>
      <value value="47"/>
      <value value="48"/>
      <value value="49"/>
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="8scenario_s4_rerun" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 80</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competition_value">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="value-influence">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion">
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type">
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold">
      <value value="0.1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold">
      <value value="0.7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
      <value value="31"/>
      <value value="32"/>
      <value value="33"/>
      <value value="34"/>
      <value value="35"/>
      <value value="36"/>
      <value value="37"/>
      <value value="38"/>
      <value value="39"/>
      <value value="40"/>
      <value value="41"/>
      <value value="42"/>
      <value value="43"/>
      <value value="44"/>
      <value value="45"/>
      <value value="46"/>
      <value value="47"/>
      <value value="48"/>
      <value value="49"/>
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="validate_reform_baseline" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 50</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="validate_reform_enclave" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 50</exitCondition>
    <metric>ticks</metric>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="validate_reform_e23" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 50</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type">
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="validate_reform_e23_resume_s4e2" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 50</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario"><value value="4"/></enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type"><value value="2"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="validate_reform_e23_resume_s4e3" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 50</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario"><value value="4"/></enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type"><value value="3"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="validate_reform_main_baseline" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 50</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="validate_reform_main_enclave" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 50</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="validate_reform_main_e23" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 50</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type">
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="validate_reform_main30_baseline" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 30</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="validate_reform_main30_enclave" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 30</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="validate_reform_main30_e23" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 30</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="diagnostic_50year_designated_e3" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 50</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type"><value value="3"/></enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sens_quota_baseline" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 30</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale">
      <value value="0.5"/>
      <value value="0.8"/>
      <value value="1"/>
      <value value="1.5"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sens_quota_enclave" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 30</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale">
      <value value="0.5"/>
      <value value="0.8"/>
      <value value="1"/>
      <value value="1.5"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sens_quota_e23" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 30</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale">
      <value value="0.5"/>
      <value value="0.8"/>
      <value value="1"/>
      <value value="1.5"/>
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type">
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sens_comp_baseline" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 30</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value">
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.3"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sens_comp_enclave" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 30</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value">
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.3"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sens_comp_e23" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 30</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value">
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.3"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type">
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sens_val_baseline" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 30</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence">
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.3"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sens_val_enclave" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 30</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence">
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.3"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="sens_val_e23" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 30</exitCondition>
    <metric>gini-gdp</metric>
    <metric>mean [industrial_land_price_per] of local_governments with [real = 1]</metric>
    <metric>mean [gdp_companies] of local_governments with [real = 1]</metric>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <metric>mean [company_number] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence">
      <value value="0.1"/>
      <value value="0.2"/>
      <value value="0.3"/>
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario">
      <value value="3"/>
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type">
      <value value="2"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="seed_value">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
      <value value="11"/>
      <value value="12"/>
      <value value="13"/>
      <value value="14"/>
      <value value="15"/>
      <value value="16"/>
      <value value="17"/>
      <value value="18"/>
      <value value="19"/>
      <value value="20"/>
      <value value="21"/>
      <value value="22"/>
      <value value="23"/>
      <value value="24"/>
      <value value="25"/>
      <value value="26"/>
      <value value="27"/>
      <value value="28"/>
      <value value="29"/>
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="smoke_test_160fix" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks &gt;= 15</exitCondition>
    <metric>mean [gdp] of local_governments with [real = 1]</metric>
    <enumeratedValueSet variable="creation_proportion"><value value="0"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_value"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="share_proportion"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="value-influence"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="hyber_link_count"><value value="10"/></enumeratedValueSet>
    <enumeratedValueSet variable="hatch_proportion"><value value="1.0E-4"/></enumeratedValueSet>
    <enumeratedValueSet variable="quota-scale"><value value="1"/></enumeratedValueSet>
    <enumeratedValueSet variable="recovery_rate"><value value="0.05"/></enumeratedValueSet>
    <enumeratedValueSet variable="competition_threshold"><value value="0.1"/></enumeratedValueSet>
    <enumeratedValueSet variable="utilization_threshold"><value value="0.7"/></enumeratedValueSet>
    <enumeratedValueSet variable="scenario"><value value="4"/></enumeratedValueSet>
    <enumeratedValueSet variable="enclave_type"><value value="3"/></enumeratedValueSet>
    <enumeratedValueSet variable="seed_value"><value value="1"/></enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
