Session.set 'fonts_active', false
WebFontConfig = 
  active: -> Session.set('fonts_active', true)
  logo_fonts: [ 
    'Graduate', 'Nova Square', 'Bangers', 'Carter One', 'Sansita One', 'Arvo'
  ],
  site_fonts: ['Lato']

WebFontConfig.fonts = WebFontConfig.logo_fonts.concat(WebFontConfig.site_fonts)

# assumes all the fonts are latin..
WebFontConfig.google =
  families: (f.replace(' ', '+') + '::latin' for f in WebFontConfig.fonts)