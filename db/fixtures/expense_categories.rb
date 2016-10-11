ExpenseCategory.seed_once(:name, :organization_id,
  { name: 'Paint', major_expense: true, organization_id: 0 },
  { name: 'Wood', major_expense: true, organization_id: 0 },
  { name: 'Labor', major_expense: true, organization_id: 0 },
  { name: 'Drywall', major_expense: false, organization_id: 0 }
)
