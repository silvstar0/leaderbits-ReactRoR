irb(main):009:0> charges = Stripe::Charge.list(customer: 'cus_DnrSfeEnr1e3gt')

irb(main):010:0> charges.first[:receipt_url]
=> "https://pay.stripe.com/receipts/acct_1CTuO0BtjjIyBvba/ch_1DkvFNBtjjIyBvba740o3Um8/rcpt_EDLxpHF4Lmj0idF5cjctYUzQycWIdsh"

customers = Stripe::Customer.all(limit: 10000).data

customers.each do |customer|
  user = User.where(email: customer[:email]).first
  
  if user.present?
    if user.organization.stripe_customer_id.present?
      puts "Skipping for #{user.email}"
      next
    end
    
    puts "Setting #{customer.id} for #{user.email}"
    user.organization.update_column :stripe_customer_id, customer.id
  else
    puts "can not match #{customer[:email]}"
  end
end ; nil