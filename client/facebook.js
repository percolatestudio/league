Facebook = {
  channelUrl: '//' + window.location.hostname + '/facebook_channel',
  appId: window.location.hostname == 'localhost' ? '227688344011052' : '246944062081485',
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