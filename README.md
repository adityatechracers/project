CorkCRM
=======

[![Build Status](http://jenkins.webascender.com/buildStatus/icon?job=corkcrm)](http://jenkins.webascender.com/job/corkcrm/)

Development Setup
-----------------

```bash
git clone git@github.com:web-ascender/corkcrm.git
cd corkcrm && bundle

cp config/database.yml.example config/database.yml
p config/stripe.yml.example config/stripe.yml
+cp config/mandrill.yml.example config/mandrill.yml

rake db:create && rake db:migrate && rake db:seed && rake db:seed_fu
```

| Ruby      | Rails  |
| --------- | ------ |
| 1.9.3     | 3.2.13 |



Development
============

Backup & Restoring Database example:

pg_dump corkcrm_staging -U corkcrm -h localhost -F c > corkcrm_feb_21_2015.sql
pg_restore --verbose --clean --no-acl --no-owner -h localhost -d corkcrm_development corkcrm_bk.sql


If you get a backup of production to use in development/staging to test reporting or features.
Obfuscate email addresses to prevent any unexpected emails from being delivered.

Contact.all.each do |contact|
  contact.update_column(:email,"contact_#{contact.id}+corkcrm@cognitelabs.com")
end

Inquiry.all.each do |inquiry|
  inquiry.update_column(:email, "inquiry_#{inquiry.id}+corkcrm@cognitelabs.com")
end

Organization.all.each do |organization|
  if organization.email && !organization.email.include?("cognitelabs.com")
    organization.update_column(:email,"organization_#{organization.id}+corkcrm@cognitelabs.com")
  end
end

User.all.each do |user|
  if user.email && !user.email.include?("cognitelabs.com")
    user.update_column(:email,"user_#{user.id}+corkcrm@cognitelabs.com")
  end
end

Backup
======
To back up the database

```pg_dump -U corkcrm corkcrm_production > file_name.sql```

To restore the database

```psql -U corkcrm corkcrm_production < file_name.sql```

