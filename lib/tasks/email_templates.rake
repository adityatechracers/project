namespace :email_templates do
  task :copy_content_to_french_versions => :environment do
    EmailTemplate.where(lang: 'fr-CA').each do |french_tmpl| 
      english_tmpl = EmailTemplate.where(name: french_tmpl.name, lang: 'en').first
      french_tmpl.update_attributes(
        subject: english_tmpl.subject, 
        body: english_tmpl.body
      )
    end
  end
end
