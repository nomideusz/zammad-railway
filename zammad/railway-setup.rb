# Runs on every boot, after zammad-init (migrations). Keeps the URL settings in
# step with the service variables, and on the very first boot creates the admin
# with Zammad's own auto wizard, so the setup page is never open to whoever
# finds the URL first.
Setting.set('fqdn', ENV['ZAMMAD_FQDN']) if ENV['ZAMMAD_FQDN'].present?
Setting.set('http_type', ENV['ZAMMAD_HTTP_TYPE']) if ENV['ZAMMAD_HTTP_TYPE'].present?

exit if User.admin_user_exists?(except_user_id: [1])

email = ENV['ZAMMAD_ADMIN_EMAIL'].to_s.strip
abort 'ZAMMAD_ADMIN_EMAIL is empty: set it to create the admin' if email.empty?
org = ENV['ZAMMAD_ORGANIZATION'].presence || 'My Company'

File.write(Rails.root.join('auto_wizard.json'), {
  'TextModuleLocale' => { 'Locale' => 'en-us' },
  'Organizations'    => [{ 'name' => org }],
  'Users'            => [{
    'login'        => email,
    'email'        => email,
    'firstname'    => 'Admin',
    'lastname'     => org,
    'organization' => org,
    'password'     => ENV.fetch('ZAMMAD_ADMIN_PASSWORD'),
  }],
  'Settings'         => [
    { 'name' => 'organization', 'value' => org },
    { 'name' => 'system_online_service', 'value' => false },
  ],
}.to_json)
AutoWizard.setup
Service::System::CheckSetup.done?
puts "Created admin #{email}"
