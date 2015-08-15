quotes = [
  [
    "I've missed more than 9000 shots in my career. I've lost almost 300 games. 26 times, I've been trusted to take the game winning shot and missed. I've failed over and over and over again in my life. And that is why I succeed.",
    'Michael Jordan'
  ],
  [
    'High expectations are the key to everything.',
    'Sam Walton'
  ],
  [
    'What good is an idea if it remains an idea? Try. Experiment. Iterate. Fail. Try again. Change the world.',
    'Simon Sinek'
  ],
  [
    'Do or do not. There is no try.',
    'Yoda'
  ],
  [
    'Change before you have to.',
    'Jack Welch'
  ],
  [
    'The critical ingredient is getting off your butt and doing something. The true entrepreneur is a doer, not a dreamer.',
    'Nolan Bushnell, founder of Atari'
  ],
  [
    'See things in the present even if they are in the future.',
    'Larry Ellison, co-founder of Oracle'
  ],
  [
    'The secret to successful hiring is this: look for the people who want to change the world.',
    'Marc Benioff, CEO of Salesforce'
  ],
  [
    "Don't find customers for your products, find products for your customers.",
    'Seth Godin'
  ],
  [
    'Good design means never having to say "Click Here."',
    'Shawn Leslie, Product Designer at Digital Telepathy'
  ],
  [
    'A brand is no longer what we tell consumer it is, it is what consumers tell each other it is.',
    'Scott Cook, co-founder of Intuit'
  ],
  [
    "Don't be threatened by people smarter than you.",
    'Howard Schultz, CEO of Starbucks'
  ],
  [
    'Move out of your comfort zone. You can only grow if you are willing to feel awkward and uncomfortable when you try something new.',
    'Brian Tracy'
  ],
  [
    "I am thankful for all of those who said 'no' to me. Its because of them I'm doing it myself.",
    'Albert Einstein'
  ],
  [
    "It doesn't make sense to hire smart people and then tell them what to do; we hire smart people so they can tell us what to do.",
    'Steve Jobs'
  ],
  [
    'A successful business, at its core, is thousands of small decisions made correctly.',
    'Mitchell Harper, Co-founder of Bigcommerce'
  ],
  [
    'Progress, not perfection.',
    'Lauris Liberts, Draugiem Group'
  ],
  [
    'Be undeniably good. No marketing effort or social media buzzword can be a substitute for that.',
    'Anthony Volodkin, founder of Hype Machine'
  ],
  [
    'Success is how well you do what you do when nobody else is looking.',
    'John Paul DeJoria'
  ],
  [
    "A brilliant idea doesn't guarantee a successful invention. Real magic comes from a brilliant idea combined with willpower, tenacity, and a willingness to make mistakes.",
    'Lori Greiner'
  ],
  [
    "Lots of companies don't succeed over time. What do they fundamentally do wrong? They usually miss the future.",
    'Larry Page, CEO of Google'
  ],
  [
    'Price is what you pay. Value is what you get.',
    'Warren Buffett '
  ],
  [
    "Doing something that doesn't end up working > Not doing something because of the fear it won't work.",
    'Aaron Levie, Box.net'
  ],
  [
    'The best new ideas live at the boundary between the real world and software.',
    "Adam MacBeth, hardware specialist, shaped the iPod and Jawbone's wristbands"
  ]
]

quotes.each do |quote|
  Quote.create!(quote: quote[0], author: quote[1])
end
