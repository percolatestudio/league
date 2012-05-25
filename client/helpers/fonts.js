WebFontConfig = {
  logo_fonts: [ 
    'Graduate', 'Nova Square', 'Bangers', 'Carter One', 'Sansita One', 'Arvo', 'Lobster Two'
  ],
  site_fonts: ['Lato']
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