WebFontConfig = {
  logo_fonts: [ 
    'Graduate', 'Sonsie One', 'Shojumaru', 'Trade Winds',  'Nova Square', 'Bangers', 'Carter One', 'Sansita One', 
    'Arvo' 
  ],
  site_fonts: ['Open Sans', 'Lato', 'PT Sans', 'Cabin']
}
WebFontConfig.fonts = WebFontConfig.logo_fonts.concat(WebFontConfig.site_fonts)

// assumes all the fonts are latin..
WebFontConfig.google = { 
  families: _.map(WebFontConfig.fonts, function(f) { 
    return f.replace(' ', '+') + '::latin'; 
  })
};

(function() {
  var wf = document.createElement('script');
  wf.src = ('https:' == document.location.protocol ? 'https' : 'http') +
    '://ajax.googleapis.com/ajax/libs/webfont/1/webfont.js';
  wf.type = 'text/javascript';
  wf.async = 'true';
  var s = document.getElementsByTagName('script')[0];
  s.parentNode.insertBefore(wf, s);
}());