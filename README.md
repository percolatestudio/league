## League

To run, install meteorite and run via `mrt`

#### Setup facebook:
```js
Meteor.call('configureLoginService', 
  {'service': 'facebook', 'appId': ID, 'secret': SECRET}, 
  function(e) {
     console.log(e)
  }
)
```