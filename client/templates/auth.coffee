Template.auth.logged_in = -> AuthSystem.logged_in()

Template.logged_in_user.current_user = -> current_user()
Template.logged_in_user.facebook_profile_url = -> this.facebook_profile_url('square')