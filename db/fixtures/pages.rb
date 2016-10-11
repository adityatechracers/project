Page.seed_once(:name,
  {:name => "Home"},
  {:name => "About"},
  {:name => "Features"},
  {:name => "Pricing & Plans"},
  {:name => "Blog"},
  {:name => "Contact"},
  {:name => "Terms of Service"}
)

PageItem.seed_once(:name, :page_id,
  {
    :page_id => 1,
    :name => "Why CorkCRM is Different",
    :content => "<h2>Why CorkCRM is Different</h2><p>Nunc quis orci dui. Pellentesque non mi vitae nulla tincidunt euismod id ut odio. Fusce non est nec nulla lacinia lobortis. Nullam vulputate magna non nisl elementum tempor.</p><p>Nunc nibh magna, sodales in ullamcorper sit amet, accumsan et est. Duis consequat, nulla ut consequat posuere, metus leo ullamcorper odio, vel sagittis orci neque eget ligula. Etiam imperdiet lectus tempus nisi tempor semper. Ut fermentum velit id diam pellentesque vitae hendrerit urna luctus. Nulla vitae blandit sapien. Ut accumsan, diam eget ornare elementum, sapien nibh tempor est, quis convallis tellus nisl id lorem.</p>"
  },
  {
    :page_id => Page.find_by_name("Home").id,
    :name => "What CorkCRM Provides",
    :content => "<h3><img src='/assets/block-icon.png' style='margin-top:-8px;' /> What CorkCRM Provides</h3><ul><li>Nunc nibh magna, sodales in ullamcorper sit amet, accumsan et est.</li><li>Duis consequat, nulla ut consequat posuere, metus leo ullamcorper odio, vel sagittis orci neque eget ligula.</li><li>Etiam imperdiet lectus tempus nisi tempor semper.</li><li>Ut fermentum velit id diam pellentesque vitae hendrerit urna luctus.</li><li>Nulla vitae blandit sapien.</li><li>Ut accumsan, diam eget ornare elementum, sapien nibh tempor est, quis convallis tellus nisl id lorem.</li></ul>"
  },
  {
    :page_id => Page.find_by_name("Home").id,
    :name => "Feature 1",
    :content => "<img src='/assets/eye-icon.png' /><h3>Track Leads</h3><p>CorkCRM will help you prospect for customers, track their status, schedule times to call leads back.</p>"
  },
  {
    :page_id => Page.find_by_name("Home").id,
    :name => "Feature 2",
    :content => "<img src='/assets/notepad-icon.png' /><h3>Book Appointments</h3><p>Booking appointments are made easy with CorkCRM. Never feel disconnected again.</p>"
  },
  {
    :page_id => Page.find_by_name("Home").id,
    :name => "Feature 3",
    :content => "<img src='/assets/document-icon.png' /><h3>Send Proposals</h3><p>Find clients. Send prososals. Grow your business.  All made easy thanks to CorkCRM.</p>"
  },
  {
    :page_id => Page.find_by_name("Home").id,
    :name => "Feature 4",
    :content => "<img src='/assets/chat-icon.png' /><h3>Schedule Jobs</h3><p>Looking to fill the job? Use the built in scheduler to fulfill task requirements. It’s never been this easy.</p>"
  },
  {
    :page_id => Page.find_by_name("About").id,
    :name => "About Header",
    :content => "<h1>About</h1><hr/><p class='lead'>Cosby sweater raw denim PBR, forage in quis mumblecore next level fixie.</p><p>In asymmetrical Wes Anderson bicycle rights laboris ullamco, distillery typewriter butcher ut authentic meggings. Odd Future gastropub beard excepteur. Excepteur distillery jean shorts raw denim. Bitters mixtape reprehenderit ethical, Cosby sweater Helvetica authentic farm-to-table officia flannel ex laboris Pitchfork. Assumenda tofu meh, lomo jean shorts small batch Cosby sweater photo booth gastropub shabby chic magna polaroid Tonx. Hashtag 8-bit enim, irony raw denim vegan sunt mumblecore photo booth squid delectus aute church-key American Apparel. Ex fap butcher, kale chips four loko gastropub High Life placeat farm-to-table you probably haven't heard of them tote bag est.</p>"
  },
  {
    :page_id => Page.find_by_name("About").id,
    :name => "About Content",
    :content => "<p>Disrupt sriracha nostrud next level lomo roof party. McSweeney's 8-bit scenester, Odd Future duis ethical polaroid skateboard butcher synth blog. Drinking vinegar PBR sartorial, ea bespoke Banksy chia wayfarers delectus sustainable nulla VHS mumblecore High Life try-hard. Sapiente messenger bag 8-bit, Brooklyn church-key pour-over odio. Selvage sed before they sold out, butcher artisan iPhone Cosby sweater eu raw denim Pitchfork nostrud mollit. Biodiesel Austin pop-up messenger bag readymade. IPhone Portland PBR&B Echo Park cray, Tumblr kitsch cred umami irure keffiyeh.</p><p>Cosby sweater raw denim PBR, forage in quis mumblecore next level fixie. Sunt Cosby sweater scenester, gastropub cillum master cleanse small batch Helvetica whatever commodo vinyl actually quis. IPhone quinoa irony, Thundercats id dolor Odd Future organic non typewriter sustainable pickled McSweeney's cred. Exercitation occupy four loko, reprehenderit ethnic gentrify post-ironic swag sunt synth Schlitz nisi incididunt bitters. Four loko pariatur culpa pug. 3 wolf moon Tumblr mollit, qui fap kale chips assumenda chia est eiusmod. Blue Bottle ad nihil, pug pork belly deep v proident quinoa 8-bit American Apparel keytar.</p><p>In asymmetrical Wes Anderson bicycle rights laboris ullamco, distillery typewriter butcher ut authentic meggings. Odd Future gastropub beard excepteur. Excepteur distillery jean shorts raw denim. Bitters mixtape reprehenderit ethical, Cosby sweater Helvetica authentic farm-to-table officia flannel ex laboris Pitchfork. Assumenda tofu meh, lomo jean shorts small batch Cosby sweater photo booth gastropub shabby chic magna polaroid Tonx. Hashtag 8-bit enim, irony raw denim vegan sunt mumblecore photo booth squid delectus aute church-key American Apparel. Ex fap butcher, kale chips four loko gastropub High Life placeat farm-to-table you probably haven't heard of them tote bag est.</p><p>Craft beer ea banjo, meh disrupt butcher Banksy. Truffaut keffiyeh skateboard, bespoke American Apparel chia PBR ullamco. Pitchfork reprehenderit brunch synth, direct trade nulla quinoa sunt keytar Vice +1 lo-fi. Pour-over narwhal odio, in photo booth id Williamsburg Blue Bottle banjo fingerstache nulla. Hashtag kitsch selfies DIY cred. Ennui fashion axe PBR hella occupy chambray, Williamsburg Odd Future. Deserunt shabby chic Blue Bottle keffiyeh, four loko sed Pitchfork fashion axe Vice freegan velit vegan brunch.</p>"
  },
  {
    :page_id => Page.find_by_name("Features").id,
    :name => "Features Header",
    :content => "<h1>Features</h1><hr/><p class='lead'>Cosby sweater raw denim PBR, forage in quis mumblecore next level fixie.</p><p>In asymmetrical Wes Anderson bicycle rights laboris ullamco, distillery typewriter butcher ut authentic meggings. Odd Future gastropub beard excepteur. Excepteur distillery jean shorts raw denim. Bitters mixtape reprehenderit ethical, Cosby sweater Helvetica authentic farm-to-table officia flannel ex laboris Pitchfork. Assumenda tofu meh, lomo jean shorts small batch Cosby sweater photo booth gastropub shabby chic magna polaroid Tonx. Hashtag 8-bit enim, irony raw denim vegan sunt mumblecore photo booth squid delectus aute church-key American Apparel. Ex fap butcher, kale chips four loko gastropub High Life placeat farm-to-table you probably haven't heard of them tote bag est.</p>"
  },
  {
    :page_id => Page.find_by_name("Features").id,
    :name => "Features Content",
    :content => "<p>Disrupt sriracha nostrud next level lomo roof party. McSweeney's 8-bit scenester, Odd Future duis ethical polaroid skateboard butcher synth blog. Drinking vinegar PBR sartorial, ea bespoke Banksy chia wayfarers delectus sustainable nulla VHS mumblecore High Life try-hard. Sapiente messenger bag 8-bit, Brooklyn church-key pour-over odio. Selvage sed before they sold out, butcher artisan iPhone Cosby sweater eu raw denim Pitchfork nostrud mollit. Biodiesel Austin pop-up messenger bag readymade. IPhone Portland PBR&B Echo Park cray, Tumblr kitsch cred umami irure keffiyeh.</p><p>Cosby sweater raw denim PBR, forage in quis mumblecore next level fixie. Sunt Cosby sweater scenester, gastropub cillum master cleanse small batch Helvetica whatever commodo vinyl actually quis. IPhone quinoa irony, Thundercats id dolor Odd Future organic non typewriter sustainable pickled McSweeney's cred. Exercitation occupy four loko, reprehenderit ethnic gentrify post-ironic swag sunt synth Schlitz nisi incididunt bitters. Four loko pariatur culpa pug. 3 wolf moon Tumblr mollit, qui fap kale chips assumenda chia est eiusmod. Blue Bottle ad nihil, pug pork belly deep v proident quinoa 8-bit American Apparel keytar.</p><p>In asymmetrical Wes Anderson bicycle rights laboris ullamco, distillery typewriter butcher ut authentic meggings. Odd Future gastropub beard excepteur. Excepteur distillery jean shorts raw denim. Bitters mixtape reprehenderit ethical, Cosby sweater Helvetica authentic farm-to-table officia flannel ex laboris Pitchfork. Assumenda tofu meh, lomo jean shorts small batch Cosby sweater photo booth gastropub shabby chic magna polaroid Tonx. Hashtag 8-bit enim, irony raw denim vegan sunt mumblecore photo booth squid delectus aute church-key American Apparel. Ex fap butcher, kale chips four loko gastropub High Life placeat farm-to-table you probably haven't heard of them tote bag est.</p><p>Craft beer ea banjo, meh disrupt butcher Banksy. Truffaut keffiyeh skateboard, bespoke American Apparel chia PBR ullamco. Pitchfork reprehenderit brunch synth, direct trade nulla quinoa sunt keytar Vice +1 lo-fi. Pour-over narwhal odio, in photo booth id Williamsburg Blue Bottle banjo fingerstache nulla. Hashtag kitsch selfies DIY cred. Ennui fashion axe PBR hella occupy chambray, Williamsburg Odd Future. Deserunt shabby chic Blue Bottle keffiyeh, four loko sed Pitchfork fashion axe Vice freegan velit vegan brunch.</p>"
  },
  {
    :page_id => Page.find_by_name("Pricing & Plans").id,
    :name => "Pricing & Plans Header",
    :content => "<h1>Pricing & Plans</h1><hr/><p class='lead'>Cosby sweater raw denim PBR, forage in quis mumblecore next level fixie.</p><p>In asymmetrical Wes Anderson bicycle rights laboris ullamco, distillery typewriter butcher ut authentic meggings. Odd Future gastropub beard excepteur. Excepteur distillery jean shorts raw denim. Bitters mixtape reprehenderit ethical, Cosby sweater Helvetica authentic farm-to-table officia flannel ex laboris Pitchfork. Assumenda tofu meh, lomo jean shorts small batch Cosby sweater photo booth gastropub shabby chic magna polaroid Tonx. Hashtag 8-bit enim, irony raw denim vegan sunt mumblecore photo booth squid delectus aute church-key American Apparel. Ex fap butcher, kale chips four loko gastropub High Life placeat farm-to-table you probably haven't heard of them tote bag est.</p>"
  },
  {
    :page_id => Page.find_by_name("Terms of Service").id,
    :name => "ToS",
    :content => "edit this text"
  },
  {
    :page_id => Page.find_by_name("Features").id,
    :name => "Feature 1",
    :content => "<span style=\"font-size:20px;\"><strong>Track Leads</strong> — &nbsp;With our intelligent lead-tracking technology, take notes on a call or schedule a time to call back. &nbsp;Upload your leads from a list, input them manually, or let your customers enter their information directly from our&nbsp;form on your company's website. Watch the video.</span>"
  },
  {
    :page_id => Page.find_by_name("Features").id,
    :name => "Feature 2",
    :content => "<span style=\"font-size:20px;\"><strong>Book Appointments</strong> — New customers can schedule online or over the phone. &nbsp;Have multiple sales reps? &nbsp;Cork allows for multiple appointments during the same time slot. &nbsp;Best of all, you can setup the appointments calendar to make your appointments show up in your&nbsp;Google Calendar and iCal. &nbsp;For an in-depth look,&nbsp;<a data-cke-saved-href=\"http://youtu.be/iDtuPXZ_Gi8\" href=\"http://youtu.be/iDtuPXZ_Gi8\">watch the video</a>.</span>"
  },
  {
    :page_id => Page.find_by_name("Features").id,
    :name => "Feature 3",
    :content => "<span style=\"font-size:20px;\"><strong>Send Proposals</strong> — Impress your clients with sleek, custom, proposals. &nbsp;Cork's proposal generator makes it really easy to create detailed proposal forms. &nbsp;When you're at an estimate, just fill in the blanks and print it out or email it to your customer. &nbsp;For an in-depth look,&nbsp;<a data-cke-saved-href=\"http://youtu.be/r0Tt21SwrVU\" href=\"http://youtu.be/r0Tt21SwrVU\">watch the video</a>.</span>"
  },
  {
    :page_id => Page.find_by_name("Features").id,
    :name => "Feature 4",
    :content => "<span style=\"font-size:20px;\"><strong>Sign Contracts</strong> — Ditch the paperwork and sign contracts electronically. &nbsp;<a data-cke-saved-href=\"http://www.nolo.com/legal-encyclopedia/electronic-signatures-online-contracts-29495.html\" href=\"http://www.nolo.com/legal-encyclopedia/electronic-signatures-online-contracts-29495.html\">Legislation passed in 2000</a>&nbsp;makes electronic signatures just as valid as paper signatures and by collecting signatures electronically you eliminate&nbsp;the risk of losing your copy of the contract. &nbsp;Your customers&nbsp;can sign via email, or on your smart phone, tablet, or computer. &nbsp;For an in-depth look,&nbsp;<a data-cke-saved-href=\"http://youtu.be/W04w3Y0tV_s\" href=\"http://youtu.be/W04w3Y0tV_s\">watch the video</a>.</span>"
  },
  {
    :page_id => Page.find_by_name("Features").id,
    :name => "Feature 5",
    :content => "<span style=\"font-size:20px;\"><strong>Schedule Jobs</strong> — Keep your business on schedule with our built-in job scheduler. &nbsp;Just setup a time to complete the work and assign a crew to the job. &nbsp;Your crews can see for themselves when/ where they need to be. &nbsp;The job scheduler also displays hours worked compared to hours budgeted so you can keep your crews on time and on budget. &nbsp;For an in-depth look,&nbsp;<a data-cke-saved-href=\"http://youtu.be/0W-evTXXvWc\" href=\"http://youtu.be/0W-evTXXvWc\">watch the video</a>.</span>"
  },
  {
    :page_id => Page.find_by_name("Features").id,
    :name => "Feature 6",
    :content => "<span style=\"font-size:20px;\"><strong>Manage Payroll</strong> — With a few clicks on their smart phone or computer, your crews can report their hours to Cork&nbsp;daily. &nbsp;At the end of the week, review employee time entries and approve or modify them. &nbsp;Approved&nbsp;labor costs are added directly to the &nbsp;expense list for designated jobs. &nbsp;Watch the video.</span>"
  },
  {
    :page_id => Page.find_by_name("Features").id,
    :name => "Feature 7",
    :content => "<span style=\"font-size:20px;\"><strong>Record Payments and Expenses</strong> — Do you know how much you made on your last job? &nbsp;Not only does CorkCRM make&nbsp;it easy to track customer payments and job costs but we've added in lots of colorful charts&nbsp;to make understanding your businesses financials a whole lot simpler. &nbsp;Watch the video.&nbsp;</span>"
  },
  {
    :page_id => Page.find_by_name("Features").id,
    :name => "Feature 8",
    :content => "<span style=\"font-size:20px;\"><strong>Reports</strong> — Cork extracts data from all corners of your business and creates easy to understand reports on everything from this week's payroll to last year's lead distribution stats. &nbsp;Cork puts the actionable data in your hand that you need to better understand your business. &nbsp;Watch the video.</span>"
  },
  {
    :page_id => Page.find_by_name("Features").id,
    :name => "Feature 9",
    :content => "<span style=\"font-size:20px;\"><strong>Mobile</strong> — CorkCRM is a web-based application that has been specially optimized for mobile. &nbsp;That means it works on just about any device that you can use to browse the internet&nbsp;-&nbsp;iPhone and Android smart phones, tablets, and computers.</span>"
  }
)
