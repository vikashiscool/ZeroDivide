# notes:
#   1)  giving inaccurate number for subsidy...currently matching the premium amount...why?
#       is it possible that sub calc is fine(premium_cap or prior calc),
#       and is instead pulling 0 for household size by default, resulting in nil? What would this do to everything else?
#       if using to_f on nil will get 0.0 value, which could explain why subsidy value always matches premium...

module PremiumCap

  # determine if eligible for medicaid before calculating subsidy
  def medicaid_referral(income, household_size, state)
    # inputs should be: float, integer and string (lower case state abbrev)

    fpl_amt = Fpl.find_by_household_size(household_size).fpl_amt.to_f
    fpl_floor = Medicaid.find_by_state(state).fpl_floor

    # calculate fpl_income level
    fpl_income_ratio = income / fpl_amt

    # if user income is equal to or less than state Medicaid thresholds, they're eligible
    #   and we should redirect them to the state's Medicaid site application
    fpl_income_ratio <= fpl_floor[0].to_f
  end

  def calculate_premium_cap(income, household_size, state)
    # inputs should be: float, integer and string (lower case state abbrev)
    premium_cap = 0.0
    fpl_amt = Fpl.find_by_household_size(household_size).fpl_amt.to_f
    tier = Cap.order(fpl_income: :desc).pluck(:fpl_income, :premium_cap)

    # 1) Calculate the fpl_income for premium_cap lookup
    fpl_income_ratio = income/fpl_amt

    # 2) lookup premium cap by fpl_income range 
    tier_index = tier.size-1
    tier.each_with_index do |map, index|
      if map[0] < fpl_income_ratio
        tier_index = index-1
        premium_cap = map[1].to_f
        break
      end
    end
    if tier_index == -1
      premium_cap = 1.0
    else
      premium_cap=tier[tier_index][1]
    end

    premium_cap
  end
end