Spree::Sample.load_sample('option_values')
Spree::Sample.load_sample('products')

ror_baseball_jersey = Spree::Product.find_by!(name: 'Datadog Baseball Jersey')
ror_tote = Spree::Product.find_by!(name: 'Datadog Tote')
ror_bag = Spree::Product.find_by!(name: 'Datadog Bag')
ror_jr_spaghetti = Spree::Product.find_by!(name: 'Datadog Jr. Spaghetti')
ror_mug = Spree::Product.find_by!(name: 'Datadog Mug')
ror_ringer = Spree::Product.find_by!(name: 'Datadog Ringer T-Shirt')
ror_stein = Spree::Product.find_by!(name: 'Datadog Stein')
spree_baseball_jersey = Spree::Product.find_by!(name: 'Spree Baseball Jersey')
spree_stein = Spree::Product.find_by!(name: 'Monitoring Stein')
spree_jr_spaghetti = Spree::Product.find_by!(name: 'Spree Jr. Spaghetti')
spree_mug = Spree::Product.find_by!(name: 'Monitoring Mug')
spree_ringer = Spree::Product.find_by!(name: 'Spree Ringer T-Shirt')
spree_tote = Spree::Product.find_by!(name: 'Spree Tote')
spree_bag = Spree::Product.find_by!(name: 'Spree Bag')
ruby_baseball_jersey = Spree::Product.find_by!(name: 'Datadog Baseball Jersey')
apache_baseball_jersey = Spree::Product.find_by!(name: 'Apache Baseball Jersey')

small = Spree::OptionValue.where(name: 'Small').first
medium = Spree::OptionValue.where(name: 'Medium').first
large = Spree::OptionValue.where(name: 'Large').first
extra_large = Spree::OptionValue.where(name: 'Extra Large').first

red = Spree::OptionValue.where(name: 'Red').first
blue = Spree::OptionValue.where(name: 'Blue').first
green = Spree::OptionValue.where(name: 'Green').first

variants = [
  {
    product: ror_baseball_jersey,
    option_values: [small, red],
    sku: 'ROR-00001',
    cost_price: 17
  },
  {
    product: ror_baseball_jersey,
    option_values: [small, blue],
    sku: 'ROR-00002',
    cost_price: 17
  },
  {
    product: ror_baseball_jersey,
    option_values: [small, green],
    sku: 'ROR-00003',
    cost_price: 17
  },
  {
    product: ror_baseball_jersey,
    option_values: [medium, red],
    sku: 'ROR-00004',
    cost_price: 17
  },
  {
    product: ror_baseball_jersey,
    option_values: [medium, blue],
    sku: 'ROR-00005',
    cost_price: 17
  },
  {
    product: ror_baseball_jersey,
    option_values: [medium, green],
    sku: 'ROR-00006',
    cost_price: 17
  },
  {
    product: ror_baseball_jersey,
    option_values: [large, red],
    sku: 'ROR-00007',
    cost_price: 17
  },
  {
    product: ror_baseball_jersey,
    option_values: [large, blue],
    sku: 'ROR-00008',
    cost_price: 17
  },
  {
    product: ror_baseball_jersey,
    option_values: [large, green],
    sku: 'ROR-00009',
    cost_price: 17
  },
  {
    product: ror_baseball_jersey,
    option_values: [extra_large, green],
    sku: 'ROR-00010',
    cost_price: 17
  }
]

masters = {
  ror_baseball_jersey => {
    sku: 'ROR-001',
    cost_price: 17
  },
  ror_tote => {
    sku: 'ROR-00011',
    cost_price: 17
  },
  ror_bag => {
    sku: 'ROR-00012',
    cost_price: 21
  },
  ror_jr_spaghetti => {
    sku: 'ROR-00013',
    cost_price: 17
  },
  ror_mug => {
    sku: 'ROR-00014',
    cost_price: 11
  },
  ror_ringer => {
    sku: 'ROR-00015',
    cost_price: 17
  },
  ror_stein => {
    sku: 'ROR-00016',
    cost_price: 15
  },
  apache_baseball_jersey => {
    sku: 'APC-00001',
    cost_price: 17
  },
  ruby_baseball_jersey => {
    sku: 'RUB-00001',
    cost_price: 17
  },
  spree_baseball_jersey => {
    sku: 'SPR-00001',
    cost_price: 17
  },
  spree_stein => {
    sku: 'SPR-00016',
    cost_price: 15
  },
  spree_jr_spaghetti => {
    sku: 'SPR-00013',
    cost_price: 17
  },
  spree_mug => {
    sku: 'SPR-00014',
    cost_price: 11
  },
  spree_ringer => {
    sku: 'SPR-00015',
    cost_price: 17
  },
  spree_tote => {
    sku: 'SPR-00011',
    cost_price: 13
  },
  spree_bag => {
    sku: 'SPR-00012',
    cost_price: 21
  }
}

variants.each do |attrs|
  Spree::Variant.create!(attrs) if Spree::Variant.where(product_id: attrs[:product].id, sku: attrs[:sku]).none?
end

masters.each do |product, variant_attrs|
  product.master.update!(variant_attrs)
end
