var ids = {
  'localhost': '227688344011052',
  'beta.getleague.com': '246944062081485',
  'getleague.com': '246944062081485',
  'league-performance.meteor.com': '364722096930486'
}

Facebook = {
  channelUrl: '//' + window.location.hostname + '/facebook_channel',
  appId: ids[window.location.hostname],
  load: function(callback) {
    // Load the SDK Asynchronously
    (function(d){
       var js, id = 'facebook-jssdk', ref = d.getElementsByTagName('script')[0];
       if (d.getElementById(id)) {return;}
       js = d.createElement('script'); js.id = id; js.async = true;
       js.src = "//connect.facebook.net/en_US/all.js";
       ref.parentNode.insertBefore(js, ref);
     }(document));
     
     window.fbAsyncInit = callback;
  }
}