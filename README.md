## League

To run, install meteorite and run via `mrt`

#### Setup facebook:
In a browser console
```js
Meteor.call('configureLoginService', 
  {'service': 'facebook', 'appId': ID, 'secret': SECRET}, 
  function(e) {
     console.log(e)
  }
)
```