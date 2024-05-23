
  openapi = "3.0.0"
  servers = [{
    url = "https://api.twitter.com",
    description = "Twitter API"
  }]
  info {
    title = "Twitter API v2"
    description = "Twitter API v2 available endpoints"
    termsOfService = "https://developer.twitter.com/en/developer-terms/agreement-and-policy.html"
    version = "2.98"
    contact {
      name = "Twitter Developers"
      url = "https://developer.twitter.com/"
    }
    license {
      name = "Twitter Developer Agreement and Policy"
      url = "https://developer.twitter.com/en/developer-terms/agreement-and-policy.html"
    }
  }
  tags "Compliance" {
    description = "Endpoints related to keeping X data in your systems compliant"
    externalDocs {
      url = "https://developer.twitter.com/en/docs/twitter-api/compliance/batch-tweet/introduction"
      description = "Find out more"
    }
  }
  tags "Direct Messages" {
    description = "Endpoints related to retrieving, managing Direct Messages"
    externalDocs {
      description = "Find out more"
      url = "https://developer.twitter.com/en/docs/twitter-api/direct-messages"
    }
  }
  tags "General" {
    description = "Miscellaneous endpoints for general API functionality"
    externalDocs {
      url = "https://developer.twitter.com/en/docs/twitter-api"
      description = "Find out more"
    }
  }
  tags "Lists" {
    description = "Endpoints related to retrieving, managing Lists"
    externalDocs {
      description = "Find out more"
      url = "https://developer.twitter.com/en/docs/twitter-api/lists"
    }
  }
  tags "Spaces" {
    description = "Endpoints related to retrieving, managing Spaces"
    externalDocs {
      description = "Find out more"
      url = "https://developer.twitter.com/en/docs/twitter-api/spaces"
    }
  }
  tags "Tweets" {
    description = "Endpoints related to retrieving, searching, and modifying Tweets"
    externalDocs {
      description = "Find out more"
      url = "https://developer.twitter.com/en/docs/twitter-api/tweets/lookup"
    }
  }
  tags "Users" {
    description = "Endpoints related to retrieving, managing relationships of Users"
    externalDocs {
      url = "https://developer.twitter.com/en/docs/twitter-api/users/lookup"
      description = "Find out more"
    }
  }
  tags "Bookmarks" {
    description = "Endpoints related to retrieving, managing bookmarks of a user"
    externalDocs {
      url = "https://developer.twitter.com/en/docs/twitter-api/bookmarks"
      description = "Find out more"
    }
  }
  paths "/2/tweets/counts/recent" "get" {
    operationId = "tweetCountsRecentSearch"
    summary = "Recent search counts"
    tags = ["Tweets"]
    parameters = [components.parameters.SearchCountFieldsParameter]
    security = [{
      BearerToken = []
    }]
    description = "Returns Post Counts from the last 7 days that match a search query."
    parameters "query" {
      schema = string(example("(from:TwitterDev OR from:TwitterAPI) has:media -is:retweet"), maxLength(4096), minLength(1))
      required = true
      in = "query"
      description = "One query/rule/filter for matching Posts. Refer to https://t.co/rulelength to identify the max query length."
      style = "form"
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The oldest UTC timestamp (from most recent 7 days) from which the Posts will be provided. Timestamp is in second granularity and is inclusive (i.e. 12:00:01 includes the first second of the minute)."
      style = "form"
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The newest, most recent UTC timestamp to which the Posts will be provided. Timestamp is in second granularity and is exclusive (i.e. 12:00:01 excludes the first second of the minute)."
      style = "form"
      schema = string(format("date-time"))
    }
    parameters "since_id" {
      in = "query"
      description = "Returns results with a Post ID greater than (that is, more recent than) the specified ID."
      style = "form"
      schema = components.schemas.TweetId
    }
    parameters "until_id" {
      in = "query"
      description = "Returns results with a Post ID less than (that is, older than) the specified ID."
      style = "form"
      schema = components.schemas.TweetId
    }
    parameters "next_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    parameters "granularity" {
      in = "query"
      description = "The granularity for the search counts results."
      style = "form"
      schema = string(default("hour"), enum("minute", "hour", "day"))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsCountsRecentResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/tweets/firehose/stream/lang/ko" "get" {
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    description = "Streams 100% of Korean Language public Posts."
    operationId = "getTweetsFirehoseStreamLangKo"
    summary = "Korean Language Firehose stream"
    tags = ["Tweets"]
    parameters "backfill_minutes" {
      description = "The number of minutes of backfill requested."
      style = "form"
      in = "query"
      schema = integer(format("int32"), maximum(5))
    }
    parameters "partition" {
      required = true
      in = "query"
      description = "The partition number."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(2))
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      style = "form"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.StreamingTweetResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/users/{id}/bookmarks/{tweet_id}" "delete" {
    operationId = "usersIdBookmarksDelete"
    summary = "Remove a bookmarked Post"
    tags = ["Bookmarks"]
    security = [{
      OAuth2UserToken = ["bookmark.write", "tweet.read", "users.read"]
    }]
    description = "Removes a Post from the requesting User's bookmarked Posts."
    parameters "id" {
      style = "simple"
      in = "path"
      description = "The ID of the authenticated source User whose bookmark is to be removed."
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
    }
    parameters "tweet_id" {
      in = "path"
      description = "The ID of the Post that the source User is removing from bookmarks."
      style = "simple"
      schema = components.schemas.TweetId
      required = true
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.BookmarkMutationResponse
      }
    }
  }
  paths "/2/users/{id}/following" "get" {
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["follows.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Following by User ID"
    description = "Returns a list of Users that are being followed by the provided User ID"
    operationId = "usersIdFollowing"
    parameters "id" {
      description = "The ID of the User to lookup."
      style = "simple"
      example = ""2244994945""
      schema = components.schemas.UserId
      required = true
      in = "path"
    }
    parameters "max_results" {
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(1000))
      in = "query"
      description = "The maximum number of results."
    }
    parameters "pagination_token" {
      style = "form"
      schema = components.schemas.PaginationToken32
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdFollowingResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/following" "post" {
    description = "Causes the User(in the path) to follow, or “request to follow” for protected Users, the target User. The User(in the path) must match the User context authorizing the request"
    operationId = "usersIdFollow"
    tags = ["Users"]
    security = [{
      OAuth2UserToken = ["follows.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Follow User"
    parameters "id" {
      in = "path"
      description = "The ID of the authenticated source User that is requesting to follow the target User."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.UsersFollowingCreateRequest
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UsersFollowingCreateResponse
      }
    }
  }
  paths "/2/users/{id}/likes" "post" {
    operationId = "usersIdLike"
    summary = "Causes the User (in the path) to like the specified Post"
    description = "Causes the User (in the path) to like the specified Post. The User in the path must match the User context authorizing the request."
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["like.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      description = "The ID of the authenticated source User that is requesting to like the Post."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.UsersLikesCreateRequest
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UsersLikesCreateResponse
      }
    }
  }
  paths "/2/lists/{id}/members/{user_id}" "delete" {
    summary = "Remove a List member"
    description = "Causes a User to be removed from the members of a List."
    operationId = "listRemoveMember"
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      style = "simple"
      schema = components.schemas.ListId
      required = true
      in = "path"
      description = "The ID of the List to remove a member."
    }
    parameters "user_id" {
      required = true
      description = "The ID of User that will be removed from the List."
      style = "simple"
      in = "path"
      schema = components.schemas.UserId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListMutateResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/tweets/counts/all" "get" {
    parameters = [components.parameters.SearchCountFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Full archive search counts"
    description = "Returns Post Counts that match a search query."
    operationId = "tweetCountsFullArchiveSearch"
    tags = ["Tweets"]
    parameters "query" {
      required = true
      in = "query"
      description = "One query/rule/filter for matching Posts. Refer to https://t.co/rulelength to identify the max query length."
      style = "form"
      schema = string(example("(from:TwitterDev OR from:TwitterAPI) has:media -is:retweet"), maxLength(4096), minLength(1))
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The oldest UTC timestamp (from most recent 7 days) from which the Posts will be provided. Timestamp is in second granularity and is inclusive (i.e. 12:00:01 includes the first second of the minute)."
      style = "form"
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      style = "form"
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The newest, most recent UTC timestamp to which the Posts will be provided. Timestamp is in second granularity and is exclusive (i.e. 12:00:01 excludes the first second of the minute)."
    }
    parameters "since_id" {
      style = "form"
      schema = components.schemas.TweetId
      in = "query"
      description = "Returns results with a Post ID greater than (that is, more recent than) the specified ID."
    }
    parameters "until_id" {
      in = "query"
      description = "Returns results with a Post ID less than (that is, older than) the specified ID."
      style = "form"
      schema = components.schemas.TweetId
    }
    parameters "next_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    parameters "pagination_token" {
      style = "form"
      schema = components.schemas.PaginationToken36
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
    }
    parameters "granularity" {
      schema = string(default("hour"), enum("minute", "hour", "day"))
      description = "The granularity for the search counts results."
      style = "form"
      in = "query"
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsCountsAllResponse
      }
    }
  }
  paths "/2/users/{id}/pinned_lists" "get" {
    tags = ["Lists"]
    parameters = [components.parameters.ListFieldsParameter, components.parameters.ListExpansionsParameter, components.parameters.UserFieldsParameter]
    security = [{
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Get a User's Pinned Lists."
    operationId = "listUserPinnedLists"
    summary = "Get a User's Pinned Lists"
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the authenticated source User for whom to return results."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdPinnedListsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/pinned_lists" "post" {
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Pin a List"
    description = "Causes a User to pin a List."
    operationId = "listUserPin"
    parameters "id" {
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User that will pin the List."
    }
    requestBody {
      required = true
      content "application/json" {
        schema = components.schemas.ListPinnedRequest
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListPinnedResponse
      }
    }
  }
  paths "/2/users/{id}/pinned_lists/{list_id}" "delete" {
    operationId = "listUserUnpin"
    summary = "Unpin a List"
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Causes a User to remove a pinned List."
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the authenticated source User for whom to return results."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    parameters "list_id" {
      required = true
      description = "The ID of the List to unpin."
      style = "simple"
      in = "path"
      schema = components.schemas.ListId
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListUnpinResponse
      }
    }
  }
  paths "/2/users/{id}/retweets" "post" {
    summary = "Causes the User (in the path) to repost the specified Post."
    description = "Causes the User (in the path) to repost the specified Post. The User in the path must match the User context authorizing the request."
    operationId = "usersIdRetweets"
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["tweet.read", "tweet.write", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User that is requesting to repost the Post."
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.UsersRetweetsCreateRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UsersRetweetsCreateResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/retweets/{source_tweet_id}" "delete" {
    operationId = "usersIdUnretweets"
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["tweet.read", "tweet.write", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Causes the User (in the path) to unretweet the specified Post"
    description = "Causes the User (in the path) to unretweet the specified Post. The User must match the User context authorizing the request"
    parameters "id" {
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User that is requesting to repost the Post."
    }
    parameters "source_tweet_id" {
      required = true
      style = "simple"
      in = "path"
      description = "The ID of the Post that the User is requesting to unretweet."
      schema = components.schemas.TweetId
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UsersRetweetsDeleteResponse
      }
    }
  }
  paths "/2/users/{source_user_id}/following/{target_user_id}" "delete" {
    description = "Causes the source User to unfollow the target User. The source User must match the User context authorizing the request"
    operationId = "usersIdUnfollow"
    summary = "Unfollow User"
    tags = ["Users"]
    security = [{
      OAuth2UserToken = ["follows.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "source_user_id" {
      description = "The ID of the authenticated source User that is requesting to unfollow the target User."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
    }
    parameters "target_user_id" {
      description = "The ID of the User that the source User is requesting to unfollow."
      schema = components.schemas.UserId
      required = true
      style = "simple"
      in = "path"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UsersFollowingDeleteResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/spaces/{id}" "get" {
    summary = "Space lookup by Space ID"
    description = "Returns a variety of information about the Space specified by the requested ID"
    operationId = "findSpaceById"
    tags = ["Spaces"]
    parameters = [components.parameters.SpaceFieldsParameter, components.parameters.SpaceExpansionsParameter, components.parameters.UserFieldsParameter, components.parameters.TopicFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the Space to be retrieved."
      style = "simple"
      example = "1YqKDqWqdPLsV"
      schema = string(description("The unique identifier of this Space."), example("1SLjjRYNejbKM"), pattern("^[a-zA-Z0-9]{1,13}$"))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2SpacesIdResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/lists/{id}/members" "get" {
    summary = "Returns User objects that are members of a List by the provided List ID."
    description = "Returns a list of Users that are members of a List by the provided List ID."
    operationId = "listGetMembers"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the List."
      style = "simple"
      schema = components.schemas.ListId
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationTokenLong
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2ListsIdMembersResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/lists/{id}/members" "post" {
    operationId = "listAddMember"
    summary = "Add a List member"
    description = "Causes a User to become a member of a List."
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      style = "simple"
      schema = components.schemas.ListId
      required = true
      in = "path"
      description = "The ID of the List for which to add a member."
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.ListAddUserRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListMutateResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/spaces/by/creator_ids" "get" {
    parameters = [components.parameters.SpaceFieldsParameter, components.parameters.SpaceExpansionsParameter, components.parameters.UserFieldsParameter, components.parameters.TopicFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    summary = "Space lookup by their creators"
    description = "Returns a variety of information about the Spaces created by the provided User IDs"
    operationId = "findSpacesByCreatorIds"
    tags = ["Spaces"]
    parameters "user_ids" {
      schema = array([components.schemas.UserId], maxItems(100), minItems(1))
      required = true
      in = "query"
      description = "The IDs of Users to search through."
      style = "form"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2SpacesByCreatorIdsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/spaces/{id}/tweets" "get" {
    summary = "Retrieve Posts from a Space."
    description = "Retrieves Posts shared in the specified Space."
    operationId = "spaceTweets"
    tags = ["Spaces", "Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the Space to be retrieved."
      style = "simple"
      example = "1YqKDqWqdPLsV"
      schema = string(description("The unique identifier of this Space."), example("1SLjjRYNejbKM"), pattern("^[a-zA-Z0-9]{1,13}$"))
    }
    parameters "max_results" {
      in = "query"
      description = "The number of Posts to fetch from the provided space. If not provided, the value will default to the maximum of 100."
      style = "form"
      schema = integer(format("int32"), default(100), example(25), minimum(1), maximum(100))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2SpacesIdTweetsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets" "get" {
    description = "Returns a variety of information about the Post specified by the requested ID."
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    operationId = "findTweetsById"
    summary = "Post lookup by Post IDs"
    parameters "ids" {
      description = "A comma separated list of Post IDs. Up to 100 are allowed in a single request."
      style = "form"
      schema = array([components.schemas.TweetId], maxItems(100), minItems(1))
      required = true
      in = "query"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets" "post" {
    description = "Causes the User to create a Post under the authorized account."
    operationId = "createTweet"
    summary = "Creation of a Post"
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["tweet.read", "tweet.write", "users.read"]
    }, {
      UserToken = []
    }]
    requestBody {
      required = true
      content "application/json" {
        schema = components.schemas.TweetCreateRequest
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
    responses "201" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.TweetCreateResponse
      }
    }
  }
  paths "/2/tweets/sample/stream" "get" {
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    description = "Streams a deterministic 1% of public Posts."
    operationId = "sampleStream"
    summary = "Sample stream"
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.StreamingTweetResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/tweets/search/all" "get" {
    summary = "Full-archive search"
    description = "Returns Posts that match a search query."
    operationId = "tweetsFullarchiveSearch"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    parameters "query" {
      required = true
      in = "query"
      description = "One query/rule/filter for matching Posts. Refer to https://t.co/rulelength to identify the max query length."
      style = "form"
      schema = string(example("(from:TwitterDev OR from:TwitterAPI) has:media -is:retweet"), maxLength(4096), minLength(1))
    }
    parameters "start_time" {
      style = "form"
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The oldest UTC timestamp from which the Posts will be provided. Timestamp is in second granularity and is inclusive (i.e. 12:00:01 includes the first second of the minute)."
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The newest, most recent UTC timestamp to which the Posts will be provided. Timestamp is in second granularity and is exclusive (i.e. 12:00:01 excludes the first second of the minute)."
      style = "form"
      schema = string(format("date-time"))
    }
    parameters "since_id" {
      in = "query"
      description = "Returns results with a Post ID greater than (that is, more recent than) the specified ID."
      style = "form"
      schema = components.schemas.TweetId
    }
    parameters "until_id" {
      schema = components.schemas.TweetId
      in = "query"
      description = "Returns results with a Post ID less than (that is, older than) the specified ID."
      style = "form"
    }
    parameters "max_results" {
      description = "The maximum number of search results to be returned by a request."
      style = "form"
      schema = integer(format("int32"), default(10), minimum(10), maximum(500))
      in = "query"
    }
    parameters "next_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    parameters "sort_order" {
      style = "form"
      schema = string(enum("recency", "relevancy"))
      in = "query"
      description = "This order in which to return results."
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsSearchAllResponse
      }
    }
  }
  paths "/2/tweets/{id}/liking_users" "get" {
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["like.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Returns a list of Users that have liked the provided Post ID"
    operationId = "tweetsIdLikingUsers"
    summary = "Returns User objects that have liked the provided Post ID"
    parameters "id" {
      schema = components.schemas.TweetId
      required = true
      in = "path"
      description = "A single Post ID."
      style = "simple"
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsIdLikingUsersResponse
      }
    }
  }
  paths "/2/compliance/jobs" "get" {
    tags = ["Compliance"]
    parameters = [components.parameters.ComplianceJobFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "List Compliance Jobs"
    description = "Returns recent Compliance Jobs for a given job type and optional job status"
    operationId = "listBatchComplianceJobs"
    parameters "type" {
      required = true
      in = "query"
      description = "Type of Compliance Job to list."
      style = "form"
      schema = string(enum("tweets", "users"))
    }
    parameters "status" {
      description = "Status of Compliance Job to list."
      style = "form"
      in = "query"
      schema = string(enum("created", "in_progress", "failed", "complete"))
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2ComplianceJobsResponse
      }
    }
  }
  paths "/2/compliance/jobs" "post" {
    operationId = "createBatchComplianceJob"
    tags = ["Compliance"]
    security = [{
      BearerToken = []
    }]
    summary = "Create compliance job"
    description = "Creates a compliance for the given job type"
    requestBody {
      required = true
      content "application/json" {
        schema = components.schemas.CreateComplianceJobRequest
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.CreateComplianceJobResponse
      }
    }
  }
  paths "/2/users/{id}/likes/{tweet_id}" "delete" {
    summary = "Causes the User (in the path) to unlike the specified Post"
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["like.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Causes the User (in the path) to unlike the specified Post. The User must match the User context authorizing the request"
    operationId = "usersIdUnlike"
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the authenticated source User that is requesting to unlike the Post."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    parameters "tweet_id" {
      required = true
      in = "path"
      description = "The ID of the Post that the User is requesting to unlike."
      style = "simple"
      schema = components.schemas.TweetId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UsersLikesDeleteResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/{id}/retweeted_by" "get" {
    operationId = "tweetsIdRetweetingUsers"
    summary = "Returns User objects that have retweeted the provided Post ID"
    description = "Returns a list of Users that have retweeted the provided Post ID"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      in = "path"
      description = "A single Post ID."
      style = "simple"
      schema = components.schemas.TweetId
    }
    parameters "max_results" {
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
      in = "query"
      description = "The maximum number of results."
    }
    parameters "pagination_token" {
      schema = components.schemas.PaginationToken36
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsIdRetweetedByResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/usage/tweets" "get" {
    operationId = "getUsageTweets"
    tags = ["Usage"]
    parameters = [components.parameters.UsageFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Post Usage"
    description = "Returns the Post Usage."
    parameters "days" {
      in = "query"
      description = "The number of days for which you need usage for."
      style = "form"
      schema = integer(format("int32"), default(7), minimum(1), maximum(90))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsageTweetsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/firehose/stream/lang/ja" "get" {
    operationId = "getTweetsFirehoseStreamLangJa"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Japanese Language Firehose stream"
    description = "Streams 100% of Japanese Language public Posts."
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
    }
    parameters "partition" {
      in = "query"
      description = "The partition number."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(2))
      required = true
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.StreamingTweetResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/tweets/search/recent" "get" {
    summary = "Recent search"
    description = "Returns Posts from the last 7 days that match a search query."
    operationId = "tweetsRecentSearch"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "query" {
      style = "form"
      schema = string(example("(from:TwitterDev OR from:TwitterAPI) has:media -is:retweet"), maxLength(4096), minLength(1))
      required = true
      in = "query"
      description = "One query/rule/filter for matching Posts. Refer to https://t.co/rulelength to identify the max query length."
    }
    parameters "start_time" {
      style = "form"
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The oldest UTC timestamp from which the Posts will be provided. Timestamp is in second granularity and is inclusive (i.e. 12:00:01 includes the first second of the minute)."
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The newest, most recent UTC timestamp to which the Posts will be provided. Timestamp is in second granularity and is exclusive (i.e. 12:00:01 excludes the first second of the minute)."
      style = "form"
      schema = string(format("date-time"))
    }
    parameters "since_id" {
      style = "form"
      in = "query"
      description = "Returns results with a Post ID greater than (that is, more recent than) the specified ID."
      schema = components.schemas.TweetId
    }
    parameters "until_id" {
      style = "form"
      schema = components.schemas.TweetId
      in = "query"
      description = "Returns results with a Post ID less than (that is, older than) the specified ID."
    }
    parameters "max_results" {
      style = "form"
      in = "query"
      description = "The maximum number of search results to be returned by a request."
      schema = integer(format("int32"), default(10), minimum(10), maximum(100))
    }
    parameters "next_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    parameters "pagination_token" {
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      in = "query"
      schema = components.schemas.PaginationToken36
    }
    parameters "sort_order" {
      schema = string(enum("recency", "relevancy"))
      in = "query"
      description = "This order in which to return results."
      style = "form"
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsSearchRecentResponse
      }
    }
  }
  paths "/2/users/{id}/owned_lists" "get" {
    tags = ["Lists"]
    parameters = [components.parameters.ListFieldsParameter, components.parameters.ListExpansionsParameter, components.parameters.UserFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Get a User's Owned Lists."
    description = "Get a User's Owned Lists."
    operationId = "listUserOwnedLists"
    parameters "id" {
      description = "The ID of the User to lookup."
      style = "simple"
      example = ""2244994945""
      schema = components.schemas.UserId
      required = true
      in = "path"
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      schema = components.schemas.PaginationTokenLong
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdOwnedListsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/compliance/stream" "get" {
    operationId = "getTweetsComplianceStream"
    tags = ["Compliance"]
    security = [{
      BearerToken = []
    }]
    summary = "Posts Compliance stream"
    description = "Streams 100% of compliance data for Posts"
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
    }
    parameters "partition" {
      in = "query"
      description = "The partition number."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(4))
      required = true
    }
    parameters "start_time" {
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Post Compliance events will be provided."
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Post Compliance events will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.TweetComplianceStreamResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/spaces" "get" {
    summary = "Space lookup up Space IDs"
    description = "Returns a variety of information about the Spaces specified by the requested IDs"
    operationId = "findSpacesByIds"
    tags = ["Spaces"]
    parameters = [components.parameters.SpaceFieldsParameter, components.parameters.SpaceExpansionsParameter, components.parameters.UserFieldsParameter, components.parameters.TopicFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    parameters "ids" {
      in = "query"
      description = "The list of Space IDs to return."
      style = "form"
      schema = array([string(description("The unique identifier of this Space."), example("1SLjjRYNejbKM"), pattern("^[a-zA-Z0-9]{1,13}$"))], maxItems(100), minItems(1))
      required = true
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2SpacesResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/{tweet_id}/hidden" "put" {
    security = [{
      OAuth2UserToken = ["tweet.moderate.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Hides or unhides a reply to an owned conversation."
    operationId = "hideReplyById"
    summary = "Hide replies"
    tags = ["Tweets"]
    parameters "tweet_id" {
      description = "The ID of the reply that you want to hide or unhide."
      style = "simple"
      schema = components.schemas.TweetId
      required = true
      in = "path"
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.TweetHideRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.TweetHideResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/me" "get" {
    operationId = "findMyUser"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "User lookup me"
    description = "This endpoint returns information about the requesting User."
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersMeResponse
      }
    }
  }
  paths "/2/users/{id}/bookmarks" "get" {
    description = "Returns Post objects that have been bookmarked by the requesting User"
    operationId = "getUsersIdBookmarks"
    tags = ["Bookmarks"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      OAuth2UserToken = ["bookmark.read", "tweet.read", "users.read"]
    }]
    summary = "Bookmarks by User"
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the authenticated source User for whom to return results."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      schema = components.schemas.PaginationToken36
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdBookmarksResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/bookmarks" "post" {
    summary = "Add Post to Bookmarks"
    tags = ["Bookmarks"]
    security = [{
      OAuth2UserToken = ["bookmark.write", "tweet.read", "users.read"]
    }]
    description = "Adds a Post (ID in the body) to the requesting User's (in the path) bookmarks"
    operationId = "postUsersIdBookmarks"
    parameters "id" {
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User for whom to add bookmarks."
    }
    requestBody {
      required = true
      content "application/json" {
        schema = components.schemas.BookmarkAddRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.BookmarkMutationResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/tweets" "get" {
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "User Posts timeline by User ID"
    description = "Returns a list of Posts authored by the provided User ID"
    operationId = "usersIdTweets"
    tags = ["Tweets"]
    parameters "id" {
      in = "path"
      example = ""2244994945""
      schema = components.schemas.UserId
      required = true
      description = "The ID of the User to lookup."
      style = "simple"
    }
    parameters "since_id" {
      description = "The minimum Post ID to be included in the result set. This parameter takes precedence over start_time if both are specified."
      example = ""791775337160081409""
      schema = components.schemas.TweetId
      style = "form"
      in = "query"
    }
    parameters "until_id" {
      in = "query"
      description = "The maximum Post ID to be included in the result set. This parameter takes precedence over end_time if both are specified."
      style = "form"
      example = ""1346889436626259968""
      schema = components.schemas.TweetId
    }
    parameters "max_results" {
      schema = integer(format("int32"), minimum(5), maximum(100))
      in = "query"
      description = "The maximum number of results."
      style = "form"
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    parameters "exclude" {
      in = "query"
      description = "The set of entities to exclude (e.g. 'replies' or 'retweets')."
      style = "form"
      schema = array([string(enum("replies", "retweets"))], example(["replies", "retweets"]), minItems(1), uniqueItems(true))
    }
    parameters "start_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Posts will be provided. The since_id parameter takes precedence if it is also specified."
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
    }
    parameters "end_time" {
      style = "form"
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided. The until_id parameter takes precedence if it is also specified."
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdTweetsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/dm_conversations/with/{participant_id}/dm_events" "get" {
    summary = "Get DM Events for a DM Conversation"
    description = "Returns DM Events for a DM Conversation"
    operationId = "getDmConversationsWithParticipantIdDmEvents"
    tags = ["Direct Messages"]
    parameters = [components.parameters.DmEventFieldsParameter, components.parameters.DmEventExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["dm.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "participant_id" {
      in = "path"
      description = "The ID of the participant user for the One to One DM conversation."
      schema = components.schemas.UserId
      required = true
      style = "simple"
    }
    parameters "max_results" {
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
      in = "query"
      description = "The maximum number of results."
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken32
    }
    parameters "event_types" {
      in = "query"
      description = "The set of event_types to include in the results."
      style = "form"
      schema = array([string(enum("MessageCreate", "ParticipantsJoin", "ParticipantsLeave"))], example(["MessageCreate", "ParticipantsLeave"]), minItems(1), uniqueItems(true))
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2DmConversationsWithParticipantIdDmEventsResponse
      }
    }
  }
  paths "/2/trends/by/woeid/{woeid}" "get" {
    operationId = "getTrends"
    summary = "Trends"
    tags = ["Trends"]
    parameters = [components.parameters.TrendFieldsParameter]
    security = [{
      BearerToken = []
    }]
    description = "Returns the Trend associated with the supplied WoeId."
    parameters "woeid" {
      in = "path"
      description = "The WOEID of the place to lookup a trend for."
      example = ""2244994945""
      schema = integer(format("int32"))
      required = true
      style = "simple"
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TrendsByWoeidWoeidResponse
      }
    }
  }
  paths "/2/tweets/firehose/stream" "get" {
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Firehose stream"
    description = "Streams 100% of public Posts."
    operationId = "getTweetsFirehoseStream"
    tags = ["Tweets"]
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
    }
    parameters "partition" {
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(20))
      required = true
      in = "query"
      description = "The partition number."
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.StreamingTweetResponse
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/tweets/firehose/stream/lang/en" "get" {
    operationId = "getTweetsFirehoseStreamLangEn"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "English Language Firehose stream"
    description = "Streams 100% of English Language public Posts."
    parameters "backfill_minutes" {
      schema = integer(format("int32"), maximum(5))
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
    }
    parameters "partition" {
      in = "query"
      description = "The partition number."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(8))
      required = true
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.StreamingTweetResponse
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/tweets/search/stream/rules/counts" "get" {
    security = [{
      BearerToken = []
    }]
    description = "Returns the counts of rules from a User's active rule set, to reflect usage by project and application."
    operationId = "getRuleCount"
    summary = "Rules Count"
    tags = ["General"]
    parameters = [components.parameters.RulesCountFieldsParameter]
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsSearchStreamRulesCountsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/{id}" "get" {
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Post lookup by Post ID"
    description = "Returns a variety of information about the Post specified by the requested ID."
    operationId = "findTweetById"
    tags = ["Tweets"]
    parameters "id" {
      required = true
      description = "A single Post ID."
      style = "simple"
      in = "path"
      schema = components.schemas.TweetId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsIdResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/{id}" "delete" {
    operationId = "deleteTweetById"
    summary = "Post delete by Post ID"
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["tweet.read", "tweet.write", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Delete specified Post (in the path) by ID."
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the Post to be deleted."
      style = "simple"
      schema = components.schemas.TweetId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.TweetDeleteResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/lists/{id}" "put" {
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    operationId = "listIdUpdate"
    summary = "Update List."
    description = "Update a List that you own."
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the List to modify."
      style = "simple"
      schema = components.schemas.ListId
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.ListUpdateRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListUpdateResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/lists/{id}" "delete" {
    summary = "Delete List"
    description = "Delete a List that you own."
    operationId = "listIdDelete"
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      description = "The ID of the List to delete."
      style = "simple"
      in = "path"
      schema = components.schemas.ListId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListDeleteResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/lists/{id}" "get" {
    operationId = "listIdGet"
    summary = "List lookup by List ID."
    tags = ["Lists"]
    parameters = [components.parameters.ListFieldsParameter, components.parameters.ListExpansionsParameter, components.parameters.UserFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Returns a List."
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the List."
      style = "simple"
      schema = components.schemas.ListId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2ListsIdResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/dm_events" "get" {
    tags = ["Direct Messages"]
    parameters = [components.parameters.DmEventFieldsParameter, components.parameters.DmEventExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["dm.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Returns recent DM Events across DM conversations"
    operationId = "getDmEvents"
    summary = "Get recent DM Events"
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken32
      in = "query"
    }
    parameters "event_types" {
      style = "form"
      schema = array([string(enum("MessageCreate", "ParticipantsJoin", "ParticipantsLeave"))], example(["MessageCreate", "ParticipantsLeave"]), minItems(1), uniqueItems(true))
      in = "query"
      description = "The set of event_types to include in the results."
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2DmEventsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/likes/firehose/stream" "get" {
    operationId = "likesFirehoseStream"
    tags = ["Likes"]
    parameters = [components.parameters.LikeFieldsParameter, components.parameters.LikeExpansionsParameter, components.parameters.TweetFieldsParameter, components.parameters.UserFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Likes Firehose stream"
    description = "Streams 100% of public Likes."
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
    }
    parameters "partition" {
      required = true
      description = "The partition number."
      style = "form"
      in = "query"
      schema = integer(format("int32"), minimum(1), maximum(20))
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Likes will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      style = "form"
      in = "query"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.StreamingLikeResponse
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/lists" "post" {
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.read", "list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Create List"
    description = "Creates a new List."
    operationId = "listIdCreate"
    requestBody {
      content "application/json" {
        schema = components.schemas.ListCreateRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListCreateResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/lists/{id}/followers" "get" {
    summary = "Returns User objects that follow a List by the provided List ID"
    description = "Returns a list of Users that follow a List by the provided List ID"
    operationId = "listGetFollowers"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      style = "simple"
      in = "path"
      description = "The ID of the List."
      schema = components.schemas.ListId
    }
    parameters "max_results" {
      style = "form"
      in = "query"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
      description = "The maximum number of results."
    }
    parameters "pagination_token" {
      style = "form"
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      schema = components.schemas.PaginationTokenLong
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2ListsIdFollowersResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/spaces/search" "get" {
    operationId = "searchSpaces"
    tags = ["Spaces"]
    parameters = [components.parameters.SpaceFieldsParameter, components.parameters.SpaceExpansionsParameter, components.parameters.UserFieldsParameter, components.parameters.TopicFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    summary = "Search for Spaces"
    description = "Returns Spaces that match the provided query."
    parameters "query" {
      schema = string(example("crypto"), maxLength(2048), minLength(1))
      required = true
      in = "query"
      description = "The search query."
      style = "form"
      example = "crypto"
    }
    parameters "state" {
      style = "form"
      schema = string(default("all"), enum("live", "scheduled", "all"))
      in = "query"
      description = "The state of Spaces to search for."
    }
    parameters "max_results" {
      in = "query"
      description = "The number of results to return."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2SpacesSearchResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/spaces/{id}/buyers" "get" {
    summary = "Retrieve the list of Users who purchased a ticket to the given space"
    description = "Retrieves the list of Users who purchased a ticket to the given space"
    operationId = "spaceBuyers"
    tags = ["Spaces", "Tweets"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    parameters "id" {
      description = "The ID of the Space to be retrieved."
      example = "1YqKDqWqdPLsV"
      schema = string(description("The unique identifier of this Space."), example("1SLjjRYNejbKM"), pattern("^[a-zA-Z0-9]{1,13}$"))
      required = true
      style = "simple"
      in = "path"
    }
    parameters "pagination_token" {
      schema = components.schemas.PaginationToken32
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2SpacesIdBuyersResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/dm_conversations/{id}/dm_events" "get" {
    tags = ["Direct Messages"]
    parameters = [components.parameters.DmEventFieldsParameter, components.parameters.DmEventExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["dm.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Returns DM Events for a DM Conversation"
    operationId = "getDmConversationsIdDmEvents"
    summary = "Get DM Events for a DM Conversation"
    parameters "id" {
      description = "The DM Conversation ID."
      style = "simple"
      schema = components.schemas.DmConversationId
      required = true
      in = "path"
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken32
    }
    parameters "event_types" {
      description = "The set of event_types to include in the results."
      style = "form"
      schema = array([string(enum("MessageCreate", "ParticipantsJoin", "ParticipantsLeave"))], example(["MessageCreate", "ParticipantsLeave"]), minItems(1), uniqueItems(true))
      in = "query"
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2DmConversationsIdDmEventsResponse
      }
    }
  }
  paths "/2/users/{id}/liked_tweets" "get" {
    summary = "Returns Post objects liked by the provided User ID"
    description = "Returns a list of Posts liked by the provided User ID"
    operationId = "usersIdLikedTweets"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["like.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      description = "The ID of the User to lookup."
      style = "simple"
      example = ""2244994945""
      schema = components.schemas.UserId
      required = true
      in = "path"
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), minimum(5), maximum(100))
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdLikedTweetsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/users/{id}/list_memberships" "get" {
    operationId = "getUserListMemberships"
    tags = ["Lists"]
    parameters = [components.parameters.ListFieldsParameter, components.parameters.ListExpansionsParameter, components.parameters.UserFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Get a User's List Memberships"
    description = "Get a User's List Memberships."
    parameters "id" {
      schema = components.schemas.UserId
      required = true
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
      example = ""2244994945""
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationTokenLong
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdListMembershipsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/muting" "get" {
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["mute.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Returns User objects that are muted by the provided User ID"
    description = "Returns a list of Users that are muted by the provided User ID"
    operationId = "usersIdMuting"
    tags = ["Users"]
    parameters "id" {
      required = true
      style = "simple"
      in = "path"
      description = "The ID of the authenticated source User for whom to return results."
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    parameters "max_results" {
      schema = integer(format("int32"), default(100), minimum(1), maximum(1000))
      in = "query"
      description = "The maximum number of results."
      style = "form"
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
      schema = components.schemas.PaginationTokenLong
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdMutingResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/muting" "post" {
    security = [{
      OAuth2UserToken = ["mute.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Mute User by User ID."
    description = "Causes the User (in the path) to mute the target User. The User (in the path) must match the User context authorizing the request."
    operationId = "usersIdMute"
    tags = ["Users"]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the authenticated source User that is requesting to mute the target User."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.MuteUserRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.MuteUserMutationResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/by/username/{username}" "get" {
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "User lookup by username"
    description = "This endpoint returns information about a User. Specify User by username."
    operationId = "findUserByUsername"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    parameters "username" {
      required = true
      in = "path"
      description = "A username."
      style = "simple"
      example = "TwitterDev"
      schema = string(pattern("^[A-Za-z0-9_]{1,15}$"))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersByUsernameUsernameResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/label/stream" "get" {
    operationId = "getTweetsLabelStream"
    summary = "Posts Label stream"
    description = "Streams 100% of labeling events applied to Posts"
    tags = ["Compliance"]
    security = [{
      BearerToken = []
    }]
    parameters "backfill_minutes" {
      schema = integer(format("int32"), maximum(5))
      style = "form"
      in = "query"
      description = "The number of minutes of backfill requested."
    }
    parameters "start_time" {
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Post labels will be provided."
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
    }
    parameters "end_time" {
      in = "query"
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp from which the Post labels will be provided."
      style = "form"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.TweetLabelStreamResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/tweets/sample10/stream" "get" {
    summary = "Sample 10% stream"
    description = "Streams a deterministic 10% of public Posts."
    operationId = "getTweetsSample10Stream"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    parameters "backfill_minutes" {
      style = "form"
      in = "query"
      description = "The number of minutes of backfill requested."
      schema = integer(format("int32"), maximum(5))
    }
    parameters "partition" {
      required = true
      in = "query"
      description = "The partition number."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(2))
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      style = "form"
      in = "query"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsSample10StreamResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/tweets/{id}/retweets" "get" {
    summary = "Retrieve Posts that repost a Post."
    description = "Returns a variety of information about each Post that has retweeted the Post specified by the requested ID."
    operationId = "findTweetsThatRetweetATweet"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      schema = components.schemas.TweetId
      required = true
      in = "path"
      description = "A single Post ID."
      style = "simple"
    }
    parameters "max_results" {
      style = "form"
      in = "query"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
      description = "The maximum number of results."
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsIdRetweetsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/compliance/stream" "get" {
    tags = ["Compliance"]
    security = [{
      BearerToken = []
    }]
    summary = "Users Compliance stream"
    description = "Streams 100% of compliance data for Users"
    operationId = "getUsersComplianceStream"
    parameters "backfill_minutes" {
      style = "form"
      in = "query"
      description = "The number of minutes of backfill requested."
      schema = integer(format("int32"), maximum(5))
    }
    parameters "partition" {
      description = "The partition number."
      style = "form"
      in = "query"
      schema = integer(format("int32"), minimum(1), maximum(4))
      required = true
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the User Compliance events will be provided."
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp from which the User Compliance events will be provided."
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UserComplianceStreamResponse
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/users/search" "get" {
    summary = "User search"
    description = "Returns Users that match a search query."
    operationId = "searchUserByQuery"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "query" {
      schema = components.schemas.UserSearchQuery
      required = true
      in = "query"
      description = "TThe the query string by which to query for users."
      style = "form"
      example = "someXUser"
    }
    parameters "max_results" {
      schema = integer(format("int32"), default(100), minimum(1), maximum(1000))
      in = "query"
      description = "The maximum number of results."
      style = "form"
    }
    parameters "next_token" {
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      schema = components.schemas.PaginationToken36
      in = "query"
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersSearchResponse
      }
    }
  }
  paths "/2/users/{id}/followed_lists" "get" {
    operationId = "userFollowedLists"
    summary = "Get User's Followed Lists"
    tags = ["Lists"]
    parameters = [components.parameters.ListFieldsParameter, components.parameters.ListExpansionsParameter, components.parameters.UserFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Returns a User's followed Lists."
    parameters "id" {
      description = "The ID of the User to lookup."
      style = "simple"
      example = ""2244994945""
      schema = components.schemas.UserId
      required = true
      in = "path"
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationTokenLong
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdFollowedListsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/followed_lists" "post" {
    operationId = "listUserFollow"
    summary = "Follow a List"
    description = "Causes a User to follow a List."
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User that will follow the List."
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.ListFollowedRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListFollowedResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/dm_conversations/with/{participant_id}/messages" "post" {
    operationId = "dmConversationWithUserEventIdCreate"
    summary = "Send a new message to a user"
    tags = ["Direct Messages"]
    security = [{
      OAuth2UserToken = ["dm.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Creates a new message for a DM Conversation with a participant user by ID"
    parameters "participant_id" {
      schema = components.schemas.UserId
      required = true
      in = "path"
      description = "The ID of the recipient user that will receive the DM."
      style = "simple"
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.CreateMessageRequest
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
    responses "201" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.CreateDmEventResponse
      }
    }
  }
  paths "/2/tweets/firehose/stream/lang/pt" "get" {
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Portuguese Language Firehose stream"
    description = "Streams 100% of Portuguese Language public Posts."
    operationId = "getTweetsFirehoseStreamLangPt"
    tags = ["Tweets"]
    parameters "backfill_minutes" {
      style = "form"
      in = "query"
      schema = integer(format("int32"), maximum(5))
      description = "The number of minutes of backfill requested."
    }
    parameters "partition" {
      in = "query"
      description = "The partition number."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(2))
      required = true
    }
    parameters "start_time" {
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      style = "form"
    }
    parameters "end_time" {
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      style = "form"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.StreamingTweetResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/tweets/search/stream/rules" "get" {
    description = "Returns rules from a User's active rule set. Users can fetch all of their rules or a subset, specified by the provided rule ids."
    tags = ["Tweets"]
    security = [{
      BearerToken = []
    }]
    operationId = "getRules"
    summary = "Rules lookup"
    parameters "ids" {
      description = "A comma-separated list of Rule IDs."
      style = "form"
      schema = array([components.schemas.RuleId])
      in = "query"
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(1000), minimum(1), maximum(1000))
    }
    parameters "pagination_token" {
      in = "query"
      description = "This value is populated by passing the 'next_token' returned in a request to paginate through results."
      style = "form"
      schema = string(maxLength(16), minLength(16))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.RulesLookupResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/search/stream/rules" "post" {
    summary = "Add/Delete rules"
    description = "Add or delete rules from a User's active rule set. Users can provide unique, optionally tagged rules to add. Users can delete their entire rule set or a subset specified by rule ids or values."
    operationId = "addOrDeleteRules"
    tags = ["Tweets"]
    security = [{
      BearerToken = []
    }]
    parameters "dry_run" {
      in = "query"
      description = "Dry Run can be used with both the add and delete action, with the expected result given, but without actually taking any action in the system (meaning the end state will always be as it was when the request was submitted). This is particularly useful to validate rule changes."
      style = "form"
      schema = boolean()
    }
    parameters "delete_all" {
      schema = boolean()
      in = "query"
      description = "Delete All can be used to delete all of the rules associated this client app, it should be specified with no other parameters. Once deleted, rules cannot be recovered."
      style = "form"
    }
    requestBody {
      required = true
      content "application/json" {
        schema = components.schemas.AddOrDeleteRulesRequest
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.AddOrDeleteRulesResponse
      }
    }
  }
  paths "/2/users/by" "get" {
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "This endpoint returns information about Users. Specify Users by their username."
    operationId = "findUsersByUsername"
    summary = "User lookup by usernames"
    tags = ["Users"]
    parameters "usernames" {
      required = true
      description = "A list of usernames, comma-separated."
      style = "form"
      in = "query"
      schema = array([string(description("The X handle (screen name) of this User."), pattern("^[A-Za-z0-9_]{1,15}$"))], example("TwitterDev,TwitterAPI
"), maxItems(100), minItems(1))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersByResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/compliance/jobs/{id}" "get" {
    summary = "Get Compliance Job"
    description = "Returns a single Compliance Job by ID"
    operationId = "getBatchComplianceJob"
    tags = ["Compliance"]
    parameters = [components.parameters.ComplianceJobFieldsParameter]
    security = [{
      BearerToken = []
    }]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the Compliance Job to retrieve."
      style = "simple"
      schema = components.schemas.JobId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2ComplianceJobsIdResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/search/stream" "get" {
    summary = "Filtered stream"
    description = "Streams Posts matching the stream's active rule set."
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    operationId = "searchStream"
    parameters "backfill_minutes" {
      style = "form"
      schema = integer(format("int32"), maximum(5))
      in = "query"
      description = "The number of minutes of backfill requested."
    }
    parameters "start_time" {
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Posts will be provided."
      style = "form"
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.FilteredStreamingTweetResponse
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/tweets/{id}/quote_tweets" "get" {
    description = "Returns a variety of information about each Post that quotes the Post specified by the requested ID."
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    operationId = "findTweetsThatQuoteATweet"
    summary = "Retrieve Posts that quote a Post."
    parameters "id" {
      style = "simple"
      in = "path"
      schema = components.schemas.TweetId
      required = true
      description = "A single Post ID."
    }
    parameters "max_results" {
      schema = integer(format("int32"), default(10), minimum(10), maximum(100))
      in = "query"
      description = "The maximum number of results to be returned."
      style = "form"
    }
    parameters "pagination_token" {
      style = "form"
      schema = components.schemas.PaginationToken36
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
    }
    parameters "exclude" {
      in = "query"
      description = "The set of entities to exclude (e.g. 'replies' or 'retweets')."
      style = "form"
      schema = array([string(enum("replies", "retweets"))], example(["replies", "retweets"]), minItems(1), uniqueItems(true))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsIdQuoteTweetsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users" "get" {
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "This endpoint returns information about Users. Specify Users by their ID."
    operationId = "findUsersById"
    summary = "User lookup by IDs"
    parameters "ids" {
      required = true
      in = "query"
      description = "A list of User IDs, comma-separated. You can specify up to 100 IDs."
      style = "form"
      example = "2244994945,6253282,12"
      schema = array([components.schemas.UserId], maxItems(100), minItems(1))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/followed_lists/{list_id}" "delete" {
    summary = "Unfollow a List"
    description = "Causes a User to unfollow a List."
    operationId = "listUserUnfollow"
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      style = "simple"
      in = "path"
      description = "The ID of the authenticated source User that will unfollow the List."
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    parameters "list_id" {
      schema = components.schemas.ListId
      required = true
      in = "path"
      description = "The ID of the List to unfollow."
      style = "simple"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListFollowedResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{source_user_id}/muting/{target_user_id}" "delete" {
    tags = ["Users"]
    security = [{
      OAuth2UserToken = ["mute.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Unmute User by User ID"
    description = "Causes the source User to unmute the target User. The source User must match the User context authorizing the request"
    operationId = "usersIdUnmute"
    parameters "source_user_id" {
      required = true
      in = "path"
      description = "The ID of the authenticated source User that is requesting to unmute the target User."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    parameters "target_user_id" {
      required = true
      description = "The ID of the User that the source User is requesting to unmute."
      style = "simple"
      in = "path"
      schema = components.schemas.UserId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.MuteUserMutationResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/likes/compliance/stream" "get" {
    summary = "Likes Compliance stream"
    description = "Streams 100% of compliance data for Users"
    operationId = "getLikesComplianceStream"
    tags = ["Compliance"]
    security = [{
      BearerToken = []
    }]
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
    }
    parameters "start_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Likes Compliance events will be provided."
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp from which the Likes Compliance events will be provided."
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.LikesComplianceStreamResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/users/{id}/blocking" "get" {
    security = [{
      OAuth2UserToken = ["block.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Returns a list of Users that are blocked by the provided User ID"
    operationId = "usersIdBlocking"
    summary = "Returns User objects that are blocked by provided User ID"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    parameters "id" {
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User for whom to return results."
      style = "simple"
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(1000))
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken32
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdBlockingResponse
      }
    }
  }
  paths "/2/users/{id}/mentions" "get" {
    summary = "User mention timeline by User ID"
    description = "Returns Post objects that mention username associated to the provided User ID"
    operationId = "usersIdMentions"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
      example = ""2244994945""
      schema = components.schemas.UserId
    }
    parameters "since_id" {
      description = "The minimum Post ID to be included in the result set. This parameter takes precedence over start_time if both are specified."
      style = "form"
      schema = components.schemas.TweetId
      in = "query"
    }
    parameters "until_id" {
      in = "query"
      description = "The maximum Post ID to be included in the result set. This parameter takes precedence over end_time if both are specified."
      style = "form"
      example = ""1346889436626259968""
      schema = components.schemas.TweetId
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), minimum(5), maximum(100))
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Posts will be provided. The since_id parameter takes precedence if it is also specified."
      style = "form"
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided. The until_id parameter takes precedence if it is also specified."
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdMentionsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/dm_events/{event_id}" "get" {
    security = [{
      OAuth2UserToken = ["dm.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Returns DM Events by event id."
    operationId = "getDmEventsById"
    summary = "Get DM Events by id"
    tags = ["Direct Messages"]
    parameters = [components.parameters.DmEventFieldsParameter, components.parameters.DmEventExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.TweetFieldsParameter]
    parameters "event_id" {
      schema = components.schemas.DmEventId
      required = true
      description = "dm event id."
      style = "simple"
      in = "path"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2DmEventsEventIdResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/dm_events/{event_id}" "delete" {
    summary = "Delete Dm"
    description = "Delete a Dm Event that you own."
    operationId = "dmEventDelete"
    tags = ["Direct Messages"]
    security = [{
      OAuth2UserToken = ["dm.read", "dm.write"]
    }, {
      UserToken = []
    }]
    parameters "event_id" {
      in = "path"
      description = "The ID of the direct-message event to delete."
      style = "simple"
      schema = components.schemas.DmEventId
      required = true
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.DeleteDmResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/openapi.json" "get" {
    summary = "Returns the OpenAPI Specification document."
    description = "Full OpenAPI Specification in JSON format. (See https://github.com/OAI/OpenAPI-Specification/blob/master/README.md)"
    operationId = "getOpenApiSpec"
    tags = ["General"]
    responses "200" {
      description = "The request was successful"
      content "application/json" {
        schema = object()
      }
    }
  }
  paths "/2/users/{id}" "get" {
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "User lookup by ID"
    description = "This endpoint returns information about a User. Specify User by ID."
    operationId = "findUserById"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    parameters "id" {
      example = ""2244994945""
      schema = components.schemas.UserId
      required = true
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/users/{id}/timelines/reverse_chronological" "get" {
    description = "Returns Post objects that appears in the provided User ID's home timeline"
    operationId = "usersIdTimeline"
    summary = "User home timeline by User ID"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the authenticated source User to list Reverse Chronological Timeline Posts of."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    parameters "since_id" {
      in = "query"
      description = "The minimum Post ID to be included in the result set. This parameter takes precedence over start_time if both are specified."
      style = "form"
      example = ""791775337160081409""
      schema = components.schemas.TweetId
    }
    parameters "until_id" {
      in = "query"
      description = "The maximum Post ID to be included in the result set. This parameter takes precedence over end_time if both are specified."
      style = "form"
      example = ""1346889436626259968""
      schema = components.schemas.TweetId
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      style = "form"
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
      schema = components.schemas.PaginationToken36
    }
    parameters "exclude" {
      in = "query"
      description = "The set of entities to exclude (e.g. 'replies' or 'retweets')."
      style = "form"
      schema = array([string(enum("replies", "retweets"))], example(["replies", "retweets"]), uniqueItems(true))
    }
    parameters "start_time" {
      example = ""2021-02-01T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Posts will be provided. The since_id parameter takes precedence if it is also specified."
      style = "form"
    }
    parameters "end_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided. The until_id parameter takes precedence if it is also specified."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdTimelinesReverseChronologicalResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/likes/sample10/stream" "get" {
    summary = "Likes Sample 10 stream"
    description = "Streams 10% of public Likes."
    tags = ["Likes"]
    parameters = [components.parameters.LikeFieldsParameter, components.parameters.LikeExpansionsParameter, components.parameters.TweetFieldsParameter, components.parameters.UserFieldsParameter]
    security = [{
      BearerToken = []
    }]
    operationId = "likesSample10Stream"
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
    }
    parameters "partition" {
      required = true
      in = "query"
      description = "The partition number."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(2))
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Likes will be provided."
      style = "form"
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      example = ""2021-02-14T18:40:40.000Z""
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      style = "form"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.StreamingLikeResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/dm_conversations" "post" {
    summary = "Create a new DM Conversation"
    description = "Creates a new DM Conversation."
    operationId = "dmConversationIdCreate"
    tags = ["Direct Messages"]
    security = [{
      OAuth2UserToken = ["dm.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    requestBody {
      content "application/json" {
        schema = components.schemas.CreateDmConversationRequest
      }
    }
    responses "201" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.CreateDmEventResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/lists/{id}/tweets" "get" {
    description = "Returns a list of Posts associated with the provided List ID."
    operationId = "listsIdTweets"
    summary = "List Posts timeline by List ID."
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the List."
      style = "simple"
      schema = components.schemas.ListId
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
      in = "query"
      schema = components.schemas.PaginationToken36
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2ListsIdTweetsResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/users/{id}/followers" "get" {
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["follows.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Followers by User ID"
    description = "Returns a list of Users who are followers of the specified User ID."
    operationId = "usersIdFollowers"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
      example = ""2244994945""
      schema = components.schemas.UserId
    }
    parameters "max_results" {
      description = "The maximum number of results."
      style = "form"
      in = "query"
      schema = integer(format("int32"), minimum(1), maximum(1000))
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken32
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdFollowersResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/dm_conversations/{dm_conversation_id}/messages" "post" {
    tags = ["Direct Messages"]
    security = [{
      OAuth2UserToken = ["dm.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Creates a new message for a DM Conversation specified by DM Conversation ID"
    operationId = "dmConversationByIdEventIdCreate"
    summary = "Send a new message to a DM Conversation"
    parameters "dm_conversation_id" {
      style = "simple"
      in = "path"
      schema = string()
      required = true
      description = "The DM Conversation ID."
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.CreateMessageRequest
      }
    }
    responses "201" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.CreateDmEventResponse
      }
    }
    responses "default" {
      description = "The request has failed."
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  components "schemas" "Get2UsageTweetsResponse" {
    type = "object"
    properties {
      data = components.schemas.Usage
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "UserComplianceData" {
    description = "User compliance data."
    oneOf = [components.schemas.UserProtectComplianceSchema, components.schemas.UserUnprotectComplianceSchema, components.schemas.UserDeleteComplianceSchema, components.schemas.UserUndeleteComplianceSchema, components.schemas.UserSuspendComplianceSchema, components.schemas.UserUnsuspendComplianceSchema, components.schemas.UserWithheldComplianceSchema, components.schemas.UserScrubGeoSchema, components.schemas.UserProfileModificationComplianceSchema]
  }
  components "schemas" "UserWithheld" {
    type = "object"
    description = "Indicates withholding details for [withheld content](https://help.twitter.com/en/rules-and-policies/tweet-withheld-by-country)."
    required = ["country_codes"]
    properties {
      country_codes = array([components.schemas.CountryCode], description("Provides a list of countries where this content is not available."), minItems(1), uniqueItems(true))
      scope = string(description("Indicates that the content being withheld is a `user`."), enum("user"))
    }
  }
  components "schemas" "FullTextEntities" {
    type = "object"
    properties {
      annotations = array([{
        description = "Annotation for entities based on the Tweet text.",
        allOf = [components.schemas.EntityIndicesInclusiveInclusive, object({
          probability = number(format("double"), description("Confidence factor for annotation type."), maximum(1)),
          type = string(description("Annotation type."), example("Person")),
          normalized_text = string(description("Text used to determine annotation."), example("Barack Obama"))
        }, description("Represents the data for the annotation."))]
      }], minItems(1))
      cashtags = array([components.schemas.CashtagEntity], minItems(1))
      hashtags = array([components.schemas.HashtagEntity], minItems(1))
      mentions = array([components.schemas.MentionEntity], minItems(1))
      urls = array([components.schemas.UrlEntity], minItems(1))
    }
  }
  components "schemas" "Get2TweetsIdRetweetedByResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken
      })
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "ListDeleteResponse" {
    type = "object"
    properties {
      data = object({
        deleted = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "Media" {
    type = "object"
    required = ["type"]
    discriminator {
      propertyName = "type"
      mapping {
        photo = "#/components/schemas/Photo"
        video = "#/components/schemas/Video"
        animated_gif = "#/components/schemas/AnimatedGif"
      }
    }
    properties {
      height = components.schemas.MediaHeight
      media_key = components.schemas.MediaKey
      type = string()
      width = components.schemas.MediaWidth
    }
  }
  components "schemas" "ContextAnnotationDomainFields" {
    type = "object"
    description = "Represents the data for the context annotation domain."
    required = ["id"]
    properties {
      description = string(description("Description of the context annotation domain."))
      id = string(description("The unique id for a context annotation domain."), pattern("^[0-9]{1,19}$"))
      name = string(description("Name of the context annotation domain."))
    }
  }
  components "schemas" "DeleteDmResponse" {
    type = "object"
    properties {
      data = object({
        deleted = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "LikesComplianceStreamResponse" {
    description = "Likes compliance stream events."
    oneOf = [object({
      data = components.schemas.LikeComplianceSchema
    }, description("Compliance event."), ["data"]), object({
      errors = array([components.schemas.Problem], minItems(1))
    }, ["errors"])]
  }
  components "schemas" "End" {
    type = "string"
    format = "date-time"
    description = "The end time of the bucket."
  }
  components "schemas" "Get2TrendsByWoeidWoeidResponse" {
    type = "object"
    properties {
      data = array([components.schemas.Trend], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "TweetDeleteResponse" {
    type = "object"
    properties {
      data = object({
        deleted = boolean()
      }, ["deleted"])
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "UserProfileModificationComplianceSchema" {
    type = "object"
    required = ["user_profile_modification"]
    properties {
      user_profile_modification = components.schemas.UserProfileModificationObjectSchema
    }
  }
  components "schemas" "UserTakedownComplianceSchema" {
    type = "object"
    required = ["user", "withheld_in_countries", "event_at"]
    properties {
      user = object({
        id = components.schemas.UserId
      }, ["id"])
      withheld_in_countries = array([components.schemas.CountryCode], minItems(1))
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
    }
  }
  components "schemas" "UserWithheldComplianceSchema" {
    type = "object"
    required = ["user_withheld"]
    properties {
      user_withheld = components.schemas.UserTakedownComplianceSchema
    }
  }
  components "schemas" "Get2TweetsSearchRecentResponse" {
    type = "object"
    properties {
      data = array([components.schemas.Tweet], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "List" {
    type = "object"
    description = "A X List is a curated group of accounts."
    required = ["id", "name"]
    properties {
      owner_id = components.schemas.UserId
      private = boolean()
      created_at = string(format("date-time"))
      description = string()
      follower_count = integer()
      id = components.schemas.ListId
      member_count = integer()
      name = string(description("The name of this List."))
    }
  }
  components "schemas" "UserName" {
    pattern = "^[A-Za-z0-9_]{1,15}$"
    type = "string"
    description = "The X handle (screen name) of this user."
  }
  components "schemas" "Video" {
    allOf = [components.schemas.Media, object({
      non_public_metrics = object({
        playback_50_count = integer(format("int32"), description("Number of users who made it through 50% of the video.")),
        playback_75_count = integer(format("int32"), description("Number of users who made it through 75% of the video.")),
        playback_0_count = integer(format("int32"), description("Number of users who made it through 0% of the video.")),
        playback_100_count = integer(format("int32"), description("Number of users who made it through 100% of the video.")),
        playback_25_count = integer(format("int32"), description("Number of users who made it through 25% of the video."))
      }, description("Nonpublic engagement metrics for the Media at the time of the request.")),
      organic_metrics = object({
        playback_75_count = integer(format("int32"), description("Number of users who made it through 75% of the video.")),
        view_count = integer(format("int32"), description("Number of times this video has been viewed.")),
        playback_0_count = integer(format("int32"), description("Number of users who made it through 0% of the video.")),
        playback_100_count = integer(format("int32"), description("Number of users who made it through 100% of the video.")),
        playback_25_count = integer(format("int32"), description("Number of users who made it through 25% of the video.")),
        playback_50_count = integer(format("int32"), description("Number of users who made it through 50% of the video."))
      }, description("Organic nonpublic engagement metrics for the Media at the time of the request.")),
      preview_image_url = string(format("uri")),
      promoted_metrics = object({
        playback_0_count = integer(format("int32"), description("Number of users who made it through 0% of the video.")),
        playback_100_count = integer(format("int32"), description("Number of users who made it through 100% of the video.")),
        playback_25_count = integer(format("int32"), description("Number of users who made it through 25% of the video.")),
        playback_50_count = integer(format("int32"), description("Number of users who made it through 50% of the video.")),
        playback_75_count = integer(format("int32"), description("Number of users who made it through 75% of the video.")),
        view_count = integer(format("int32"), description("Number of times this video has been viewed."))
      }, description("Promoted nonpublic engagement metrics for the Media at the time of the request.")),
      public_metrics = object({
        view_count = integer(format("int32"), description("Number of times this video has been viewed."))
      }, description("Engagement metrics for the Media at the time of the request.")),
      variants = components.schemas.Variants,
      duration_ms = integer()
    })]
  }
  components "schemas" "OperationalDisconnectProblem" {
    description = "You have been disconnected for operational reasons."
    allOf = [components.schemas.Problem, object({
      disconnect_type = string(enum("OperationalDisconnect", "UpstreamOperationalDisconnect", "ForceDisconnect", "UpstreamUncleanDisconnect", "SlowReader", "InternalError", "ClientApplicationStateDegraded", "InvalidRules"))
    })]
  }
  components "schemas" "PollId" {
    description = "Unique identifier of this poll."
    example = "1365059861688410112"
    pattern = "^[0-9]{1,19}$"
    type = "string"
  }
  components "schemas" "DuplicateRuleProblem" {
    description = "The rule you have submitted is a duplicate."
    allOf = [components.schemas.Problem, object({
      id = string(),
      value = string()
    })]
  }
  components "schemas" "Get2DmEventsEventIdResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.DmEvent
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "MuteUserMutationResponse" {
    type = "object"
    properties {
      data = object({
        muting = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "PaginationToken32" {
    description = "A base32 pagination token."
    minLength = 16
    type = "string"
  }
  components "schemas" "TweetHideRequest" {
    type = "object"
    required = ["hidden"]
    properties {
      hidden = boolean()
    }
  }
  components "schemas" "TweetWithheldComplianceSchema" {
    type = "object"
    required = ["withheld"]
    properties {
      withheld = components.schemas.TweetTakedownComplianceSchema
    }
  }
  components "schemas" "MentionEntity" {
    allOf = [components.schemas.EntityIndicesInclusiveExclusive, components.schemas.MentionFields]
  }
  components "schemas" "RuleValue" {
    type = "string"
    description = "The filterlang value of the rule."
    example = "coffee -is:retweet"
  }
  components "schemas" "AnimatedGif" {
    allOf = [components.schemas.Media, object({
      preview_image_url = string(format("uri")),
      variants = components.schemas.Variants
    })]
  }
  components "schemas" "Get2TweetsCountsRecentResponse" {
    type = "object"
    properties {
      data = array([components.schemas.SearchCount], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      meta = object({
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        total_tweet_count = components.schemas.Aggregate
      })
    }
  }
  components "schemas" "MediaId" {
    type = "string"
    description = "The unique identifier of this Media."
    example = "1146654567674912769"
    pattern = "^[0-9]{1,19}$"
  }
  components "schemas" "Get2UsersIdResponse" {
    type = "object"
    properties {
      data = components.schemas.User
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "MentionFields" {
    type = "object"
    description = "Represent the portion of text recognized as a User mention, and its start and end position within the text."
    required = ["username"]
    properties {
      id = components.schemas.UserId
      username = components.schemas.UserName
    }
  }
  components "schemas" "DmParticipants" {
    minItems = 2
    maxItems = 49
    items = [components.schemas.UserId]
    type = "array"
    description = "Participants for the DM Conversation."
  }
  components "schemas" "Get2TweetsCountsAllResponse" {
    type = "object"
    properties {
      data = array([components.schemas.SearchCount], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      meta = object({
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        total_tweet_count = components.schemas.Aggregate,
        newest_id = components.schemas.NewestId
      })
    }
  }
  components "schemas" "UnsupportedAuthenticationProblem" {
    description = "A problem that indicates that the authentication used is not supported."
    allOf = [components.schemas.Problem]
  }
  components "schemas" "Get2UsersIdFollowersResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken
      })
      data = array([components.schemas.User], minItems(1))
    }
  }
  components "schemas" "UserSearchQuery" {
    type = "string"
    description = "The the search string by which to query for users."
    pattern = "^[A-Za-z0-9_]{1,32}$"
  }
  components "schemas" "UserSuspendComplianceSchema" {
    type = "object"
    required = ["user_suspend"]
    properties {
      user_suspend = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "BookmarkMutationResponse" {
    type = "object"
    properties {
      data = object({
        bookmarked = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "CashtagEntity" {
    allOf = [components.schemas.EntityIndicesInclusiveExclusive, components.schemas.CashtagFields]
  }
  components "schemas" "Get2TweetsIdLikingUsersResponse" {
    type = "object"
    properties {
      meta = object({
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken
      })
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "ListUpdateResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      data = object({
        updated = boolean()
      })
    }
  }
  components "schemas" "Photo" {
    allOf = [components.schemas.Media, object({
      alt_text = string(),
      url = string(format("uri"))
    })]
  }
  components "schemas" "Start" {
    type = "string"
    format = "date-time"
    description = "The start time of the bucket."
  }
  components "schemas" "StreamingLikeResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.Like
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "TweetTakedownComplianceSchema" {
    type = "object"
    required = ["tweet", "withheld_in_countries", "event_at"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      quote_tweet_id = components.schemas.TweetId
      tweet = object({
        author_id = components.schemas.UserId,
        id = components.schemas.TweetId
      }, ["id", "author_id"])
      withheld_in_countries = array([components.schemas.CountryCode], minItems(1))
    }
  }
  components "schemas" "CreateComplianceJobRequest" {
    type = "object"
    description = "A request to create a new batch compliance job."
    required = ["type"]
    properties {
      name = components.schemas.ComplianceJobName
      resumable = boolean(description("If true, this endpoint will return a pre-signed URL with resumable uploads enabled."))
      type = string(description("Type of compliance job to list."), enum("tweets", "users"))
    }
  }
  components "schemas" "DmEventId" {
    type = "string"
    description = "Unique identifier of a DM Event."
    example = "1146654567674912769"
    pattern = "^[0-9]{1,19}$"
  }
  components "schemas" "InvalidRequestProblem" {
    description = "A problem that indicates this request is invalid."
    allOf = [components.schemas.Problem, object({
      errors = array([object({
        message = string(),
        parameters = map(array([string()]))
      })], minItems(1))
    })]
  }
  components "schemas" "UserDeleteComplianceSchema" {
    type = "object"
    required = ["user_delete"]
    properties {
      user_delete = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "CreateAttachmentsMessageRequest" {
    type = "object"
    required = ["attachments"]
    properties {
      attachments = components.schemas.DmAttachments
      text = string(description("Text of the message."), minLength(1))
    }
  }
  components "schemas" "Get2TweetsSearchAllResponse" {
    type = "object"
    properties {
      data = array([components.schemas.Tweet], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "ListCreateResponse" {
    type = "object"
    properties {
      data = object({
        id = components.schemas.ListId,
        name = string(description("The name of this List."))
      }, description("A X List is a curated group of accounts."), ["id", "name"])
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "UserUnprotectComplianceSchema" {
    type = "object"
    required = ["user_unprotect"]
    properties {
      user_unprotect = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "UsersFollowingCreateRequest" {
    required = ["target_user_id"]
    type = "object"
    properties {
      target_user_id = components.schemas.UserId
    }
  }
  components "schemas" "PollOption" {
    type = "object"
    description = "Describes a choice in a Poll object."
    required = ["position", "label", "votes"]
    properties {
      votes = integer(description("Number of users who voted for this choice."))
      label = components.schemas.PollOptionLabel
      position = integer(description("Position of this choice in the poll."))
    }
  }
  components "schemas" "PollOptionLabel" {
    description = "The text of a poll choice."
    minLength = 1
    maxLength = 25
    type = "string"
  }
  components "schemas" "TweetCount" {
    type = "integer"
    description = "The count for the bucket."
  }
  components "schemas" "UploadUrl" {
    type = "string"
    format = "uri"
    description = "URL to which the user will upload their Tweet or user IDs."
  }
  components "schemas" "ConflictProblem" {
    description = "You cannot create a new job if one is already in progress."
    allOf = [components.schemas.Problem]
  }
  components "schemas" "Get2SpacesIdResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      data = components.schemas.Space
    }
  }
  components "schemas" "Get2TweetsFirehoseStreamLangKoResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2ListsIdMembersResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "MediaWidth" {
    type = "integer"
    description = "The width of the media in pixels."
  }
  components "schemas" "TweetEditComplianceObjectSchema" {
    required = ["tweet", "event_at", "initial_tweet_id", "edit_tweet_ids"]
    type = "object"
    properties {
      tweet = object({
        id = components.schemas.TweetId
      }, ["id"])
      edit_tweet_ids = array([components.schemas.TweetId], minItems(1))
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      initial_tweet_id = components.schemas.TweetId
    }
  }
  components "schemas" "RulesCapProblem" {
    description = "You have exceeded the maximum number of rules."
    allOf = [components.schemas.Problem]
  }
  components "schemas" "EntityIndicesInclusiveInclusive" {
    required = ["start", "end"]
    type = "object"
    description = "Represent a boundary range (start and end index) for a recognized entity (for example a hashtag or a mention). `start` must be smaller than `end`.  The start index is inclusive, the end index is inclusive."
    properties {
      end = integer(description("Index (zero-based) at which position this entity ends.  The index is inclusive."), example(61))
      start = integer(description("Index (zero-based) at which position this entity starts.  The index is inclusive."), example(50))
    }
  }
  components "schemas" "Get2TweetsSearchStreamResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
    }
  }
  components "schemas" "PaginationToken36" {
    type = "string"
    description = "A base36 pagination token."
    minLength = 1
  }
  components "schemas" "Get2TweetsIdRetweetsResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken
      })
      data = array([components.schemas.Tweet], minItems(1))
    }
  }
  components "schemas" "Get2TweetsResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      data = array([components.schemas.Tweet], minItems(1))
    }
  }
  components "schemas" "ListMutateResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      data = object({
        is_member = boolean()
      })
    }
  }
  components "schemas" "CreateTextMessageRequest" {
    type = "object"
    required = ["text"]
    properties {
      attachments = components.schemas.DmAttachments
      text = string(description("Text of the message."), minLength(1))
    }
  }
  components "schemas" "Get2DmConversationsIdDmEventsResponse" {
    type = "object"
    properties {
      data = array([components.schemas.DmEvent], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "Get2SpacesIdBuyersResponse" {
    type = "object"
    properties {
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "PreviousToken" {
    type = "string"
    description = "The previous token."
    minLength = 1
  }
  components "schemas" "TopicId" {
    type = "string"
    description = "Unique identifier of this Topic."
  }
  components "schemas" "TweetNoticeSchema" {
    type = "object"
    required = ["public_tweet_notice"]
    properties {
      public_tweet_notice = components.schemas.TweetNotice
    }
  }
  components "schemas" "UsageFields" {
    type = "object"
    description = "Represents the data for Usage"
    properties {
      date = string(format("date-time"), description("The time period for the usage"), example("2021-01-06T18:40:40.000Z"))
      usage = integer(format("int32"), description("The usage value"))
    }
  }
  components "schemas" "UsersLikesCreateResponse" {
    type = "object"
    properties {
      data = object({
        liked = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "Get2ComplianceJobsResponse" {
    type = "object"
    properties {
      data = array([components.schemas.ComplianceJob], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      meta = object({
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "Get2UsersIdTimelinesReverseChronologicalResponse" {
    type = "object"
    properties {
      meta = object({
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.Tweet], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Space" {
    required = ["id", "state"]
    type = "object"
    properties {
      subscriber_count = integer(format("int32"), description("The number of people who have either purchased a ticket or set a reminder for this Space."), example(10))
      updated_at = string(format("date-time"), description("When the Space was last updated."), example("2021-7-14T04:35:55Z"))
      host_ids = array([components.schemas.UserId], description("The user ids for the hosts of the Space."))
      speaker_ids = array([components.schemas.UserId], description("An array of user ids for people who were speakers in a Space."))
      state = string(description("The current state of the Space."), example("live"), enum("live", "scheduled", "ended"))
      id = components.schemas.SpaceId
      lang = string(description("The language of the Space."), example("en"))
      created_at = string(format("date-time"), description("Creation time of the Space."), example("2021-07-06T18:40:40.000Z"))
      creator_id = components.schemas.UserId
      invited_user_ids = array([components.schemas.UserId], description("An array of user ids for people who were invited to a Space."))
      is_ticketed = boolean(description("Denotes if the Space is a ticketed Space."), example(""false"
"))
      ended_at = string(format("date-time"), description("End time of the Space."), example("2021-07-06T18:40:40.000Z"))
      scheduled_start = string(format("date-time"), description("A date time stamp for when a Space is scheduled to begin."), example("2021-07-06T18:40:40.000Z"))
      topics = array([object({
        id = string(description("An ID suitable for use in the REST API.")),
        name = string(description("The name of the given topic.")),
        description = string(description("The description of the given topic."))
      }, description("The X Topic object."), example({
        description = "All about technology",
        id = "848920371311001600",
        name = "Technology"
      }), ["id", "name"])], description("The topics of a Space, as selected by its creator."))
      title = string(description("The title of the Space."), example("Spaces are Awesome"))
      started_at = string(format("date-time"), description("When the Space was started as a date string."), example("2021-7-14T04:35:55Z"))
      participant_count = integer(format("int32"), description("The number of participants in a Space."), example(10))
    }
  }
  components "schemas" "Tweet" {
    example = {
      author_id = "2244994945",
      created_at = "Wed Jan 06 18:40:40 +0000 2021",
      id = "1346889436626259968",
      text = "Learn how to use the user Tweet timeline and user mention timeline endpoints in the X API v2 to explore Tweet\u2026 https:\/\/t.co\/56a0vZUx7i"
    }
    required = ["id", "text", "edit_history_tweet_ids"]
    type = "object"
    properties {
      edit_history_tweet_ids = array([components.schemas.TweetId], description("A list of Tweet Ids in this Tweet chain."), minItems(1))
      non_public_metrics = object({
        impression_count = integer(format("int32"), description("Number of times this Tweet has been viewed."))
      }, description("Nonpublic engagement metrics for the Tweet at the time of the request."))
      in_reply_to_user_id = components.schemas.UserId
      scopes = object({
        followers = boolean(description("Indicates if this Tweet is viewable by followers without the Tweet ID"), example(false))
      }, description("The scopes for this tweet"))
      possibly_sensitive = boolean(description("Indicates if this Tweet contains URLs marked as sensitive, for example content suitable for mature audiences."), example(false))
      note_tweet = object({
        entities = object({
          cashtags = array([components.schemas.CashtagEntity], minItems(1)),
          hashtags = array([components.schemas.HashtagEntity], minItems(1)),
          mentions = array([components.schemas.MentionEntity], minItems(1)),
          urls = array([components.schemas.UrlEntity], minItems(1))
        }),
        text = components.schemas.NoteTweetText
      }, description("The full-content of the Tweet, including text beyond 280 characters."))
      context_annotations = array([components.schemas.ContextAnnotation], minItems(1))
      created_at = string(format("date-time"), description("Creation time of the Tweet."), example("2021-01-06T18:40:40.000Z"))
      source = string(description("This is deprecated."))
      lang = string(description("Language of the Tweet, if detected by X. Returned as a BCP47 language tag."), example("en"))
      attachments = object({
        media_keys = array([components.schemas.MediaKey], description("A list of Media Keys for each one of the media attachments (if media are attached)."), minItems(1)),
        media_source_tweet_id = array([components.schemas.TweetId], description("A list of Posts the media on this Tweet was originally posted in. For example, if the media on a tweet is re-used in another Tweet, this refers to the original, source Tweet.."), minItems(1)),
        poll_ids = array([components.schemas.PollId], description("A list of poll IDs (if polls are attached)."), minItems(1))
      }, description("Specifies the type of attachments (if any) present in this Tweet."))
      promoted_metrics = object({
        reply_count = integer(format("int32"), description("Number of times this Tweet has been replied to.")),
        retweet_count = integer(format("int32"), description("Number of times this Tweet has been Retweeted.")),
        impression_count = integer(format("int32"), description("Number of times this Tweet has been viewed.")),
        like_count = integer(format("int32"), description("Number of times this Tweet has been liked."))
      }, description("Promoted nonpublic engagement metrics for the Tweet at the time of the request."))
      author_id = components.schemas.UserId
      edit_controls = object({
        edits_remaining = integer(description("Number of times this Tweet can be edited.")),
        is_edit_eligible = boolean(description("Indicates if this Tweet is eligible to be edited."), example(false)),
        editable_until = string(format("date-time"), description("Time when Tweet is no longer editable."), example("2021-01-06T18:40:40.000Z"))
      }, ["is_edit_eligible", "editable_until", "edits_remaining"])
      public_metrics = object({
        reply_count = integer(description("Number of times this Tweet has been replied to.")),
        retweet_count = integer(description("Number of times this Tweet has been Retweeted.")),
        bookmark_count = integer(format("int32"), description("Number of times this Tweet has been bookmarked.")),
        impression_count = integer(format("int32"), description("Number of times this Tweet has been viewed.")),
        like_count = integer(description("Number of times this Tweet has been liked.")),
        quote_count = integer(description("Number of times this Tweet has been quoted."))
      }, description("Engagement metrics for the Tweet at the time of the request."), ["retweet_count", "reply_count", "like_count", "impression_count", "bookmark_count"])
      geo = object({
        coordinates = components.schemas.Point,
        place_id = components.schemas.PlaceId
      }, description("The location tagged on the Tweet, if the user provided one."))
      id = components.schemas.TweetId
      conversation_id = components.schemas.TweetId
      organic_metrics = object({
        impression_count = integer(description("Number of times this Tweet has been viewed.")),
        like_count = integer(description("Number of times this Tweet has been liked.")),
        reply_count = integer(description("Number of times this Tweet has been replied to.")),
        retweet_count = integer(description("Number of times this Tweet has been Retweeted."))
      }, description("Organic nonpublic engagement metrics for the Tweet at the time of the request."), ["impression_count", "retweet_count", "reply_count", "like_count"])
      reply_settings = components.schemas.ReplySettingsWithVerifiedUsers
      withheld = components.schemas.TweetWithheld
      entities = components.schemas.FullTextEntities
      referenced_tweets = array([object({
        id = components.schemas.TweetId,
        type = string(enum("retweeted", "quoted", "replied_to"))
      }, ["type", "id"])], description("A list of Posts this Tweet refers to. For example, if the parent Tweet is a Retweet, a Quoted Tweet or a Reply, it will include the related Tweet referenced to by its parent."), minItems(1))
      text = components.schemas.TweetText
    }
  }
  components "schemas" "TweetUndropComplianceSchema" {
    type = "object"
    required = ["undrop"]
    properties {
      undrop = components.schemas.TweetComplianceSchema
    }
  }
  components "schemas" "ComplianceJobType" {
    type = "string"
    description = "Type of compliance job to list."
    enum = ["tweets", "users"]
  }
  components "schemas" "CountryCode" {
    description = "A two-letter ISO 3166-1 alpha-2 country code."
    example = "US"
    pattern = "^[A-Z]{2}$"
    type = "string"
  }
  components "schemas" "StreamingTweetResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Problem" {
    type = "object"
    description = "An HTTP Problem Details object, as defined in IETF RFC 7807 (https://tools.ietf.org/html/rfc7807)."
    required = ["type", "title"]
    discriminator {
      propertyName = "type"
      mapping {
        https://api.twitter.com/2/problems/invalid-request = "#/components/schemas/InvalidRequestProblem"
        https://api.twitter.com/2/problems/resource-unavailable = "#/components/schemas/ResourceUnavailableProblem"
        https://api.twitter.com/2/problems/conflict = "#/components/schemas/ConflictProblem"
        https://api.twitter.com/2/problems/operational-disconnect = "#/components/schemas/OperationalDisconnectProblem"
        https://api.twitter.com/2/problems/usage-capped = "#/components/schemas/UsageCapExceededProblem"
        https://api.twitter.com/2/problems/noncompliant-rules = "#/components/schemas/NonCompliantRulesProblem"
        https://api.twitter.com/2/problems/resource-not-found = "#/components/schemas/ResourceNotFoundProblem"
        https://api.twitter.com/2/problems/not-authorized-for-field = "#/components/schemas/FieldUnauthorizedProblem"
        about:blank = "#/components/schemas/GenericProblem"
        https://api.twitter.com/2/problems/disallowed-resource = "#/components/schemas/DisallowedResourceProblem"
        https://api.twitter.com/2/problems/duplicate-rules = "#/components/schemas/DuplicateRuleProblem"
        https://api.twitter.com/2/problems/client-forbidden = "#/components/schemas/ClientForbiddenProblem"
        https://api.twitter.com/2/problems/client-disconnected = "#/components/schemas/ClientDisconnectedProblem"
        https://api.twitter.com/2/problems/invalid-rules = "#/components/schemas/InvalidRuleProblem"
        https://api.twitter.com/2/problems/not-authorized-for-resource = "#/components/schemas/ResourceUnauthorizedProblem"
        https://api.twitter.com/2/problems/streaming-connection = "#/components/schemas/ConnectionExceptionProblem"
        https://api.twitter.com/2/problems/oauth1-permissions = "#/components/schemas/Oauth1PermissionsProblem"
        https://api.twitter.com/2/problems/unsupported-authentication = "#/components/schemas/UnsupportedAuthenticationProblem"
        https://api.twitter.com/2/problems/rule-cap = "#/components/schemas/RulesCapProblem"
      }
    }
    properties {
      status = integer()
      title = string()
      type = string()
      detail = string()
    }
  }
  components "schemas" "AppRulesCount" {
    type = "object"
    description = "A count of user-provided stream filtering rules at the client application level."
    properties {
      rule_count = integer(format("int32"), description("Number of rules for client application"))
      client_app_id = components.schemas.ClientAppId
    }
  }
  components "schemas" "ClientAppId" {
    maxLength = 19
    type = "string"
    description = "The ID of the client application"
    minLength = 1
  }
  components "schemas" "Get2UsersIdMentionsResponse" {
    type = "object"
    properties {
      meta = object({
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount,
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId
      })
      data = array([components.schemas.Tweet], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "NoteTweetText" {
    type = "string"
    description = "The note content of the Tweet."
    example = "Learn how to use the user Tweet timeline and user mention timeline endpoints in the X API v2 to explore Tweet\u2026 https:\/\/t.co\/56a0vZUx7i"
  }
  components "schemas" "ResourceNotFoundProblem" {
    description = "A problem that indicates that a given Tweet, User, etc. does not exist."
    allOf = [components.schemas.Problem, object({
      parameter = string(minLength(1)),
      resource_id = string(),
      resource_type = string(enum("user", "tweet", "media", "list", "space")),
      value = string(description("Value will match the schema of the field."))
    }, ["parameter", "value", "resource_id", "resource_type"])]
  }
  components "schemas" "TweetDropComplianceSchema" {
    type = "object"
    required = ["drop"]
    properties {
      drop = components.schemas.TweetComplianceSchema
    }
  }
  components "schemas" "TweetUnviewableSchema" {
    type = "object"
    required = ["public_tweet_unviewable"]
    properties {
      public_tweet_unviewable = components.schemas.TweetUnviewable
    }
  }
  components "schemas" "DmEvent" {
    required = ["id", "event_type"]
    type = "object"
    properties {
      cashtags = array([components.schemas.CashtagEntity], minItems(1))
      attachments = object({
        card_ids = array([string()], description("A list of card IDs (if cards are attached)."), minItems(1)),
        media_keys = array([components.schemas.MediaKey], description("A list of Media Keys for each one of the media attachments (if media are attached)."), minItems(1))
      }, description("Specifies the type of attachments (if any) present in this DM."))
      dm_conversation_id = components.schemas.DmConversationId
      event_type = string(example("MessageCreate"))
      sender_id = components.schemas.UserId
      referenced_tweets = array([object({
        id = components.schemas.TweetId
      }, ["id"])], description("A list of Posts this DM refers to."), minItems(1))
      text = string()
      participant_ids = array([components.schemas.UserId], description("A list of participants for a ParticipantsJoin or ParticipantsLeave event_type."), minItems(1))
      created_at = string(format("date-time"))
      urls = array([components.schemas.UrlEntityDm], minItems(1))
      mentions = array([components.schemas.MentionEntity], minItems(1))
      hashtags = array([components.schemas.HashtagEntity], minItems(1))
      id = components.schemas.DmEventId
    }
  }
  components "schemas" "Get2ListsIdFollowersResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "Get2UsersIdMutingResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken
      })
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "Get2UsersByResponse" {
    type = "object"
    properties {
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "RulesCount" {
    type = "object"
    description = "A count of user-provided stream filtering rules at the application and project levels."
    properties {
      cap_per_project = integer(format("int32"), description("Cap of number of rules allowed per project"))
      client_app_rules_count = components.schemas.AppRulesCount
      project_rules_count = integer(format("int32"), description("Number of rules for project"))
      all_project_client_apps = components.schemas.AllProjectClientApps
      cap_per_client_app = integer(format("int32"), description("Cap of number of rules allowed per client application"))
    }
  }
  components "schemas" "Get2TweetsFirehoseStreamLangPtResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
    }
  }
  components "schemas" "Get2TweetsSample10StreamResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "ResourceUnauthorizedProblem" {
    description = "A problem that indicates you are not allowed to see a particular Tweet, User, etc."
    allOf = [components.schemas.Problem, object({
      section = string(enum("data", "includes")),
      value = string(),
      parameter = string(),
      resource_id = string(),
      resource_type = string(enum("user", "tweet", "media", "list", "space"))
    }, ["value", "resource_id", "resource_type", "section", "parameter"])]
  }
  components "schemas" "Point" {
    type = "object"
    description = "A [GeoJson Point](https://tools.ietf.org/html/rfc7946#section-3.1.2) geometry object."
    required = ["type", "coordinates"]
    properties {
      type = string(example("Point"), enum("Point"))
      coordinates = components.schemas.Position
    }
  }
  components "schemas" "UrlEntity" {
    description = "Represent the portion of text recognized as a URL, and its start and end position within the text."
    allOf = [components.schemas.EntityIndicesInclusiveExclusive, components.schemas.UrlFields]
  }
  components "schemas" "UsersFollowingDeleteResponse" {
    type = "object"
    properties {
      data = object({
        following = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "InvalidRuleProblem" {
    allOf = [components.schemas.Problem]
    description = "The rule you have submitted is invalid."
  }
  components "schemas" "UrlImage" {
    type = "object"
    description = "Represent the information for the URL image."
    properties {
      height = components.schemas.MediaHeight
      url = components.schemas.Url
      width = components.schemas.MediaWidth
    }
  }
  components "schemas" "UserUndeleteComplianceSchema" {
    type = "object"
    required = ["user_undelete"]
    properties {
      user_undelete = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "TweetCreateResponse" {
    type = "object"
    properties {
      data = object({
        id = components.schemas.TweetId,
        text = components.schemas.TweetText
      }, ["id", "text"])
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "JobId" {
    pattern = "^[0-9]{1,19}$"
    type = "string"
    description = "Compliance Job ID."
    example = "1372966999991541762"
  }
  components "schemas" "CreateComplianceJobResponse" {
    type = "object"
    properties {
      data = components.schemas.ComplianceJob
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "DownloadUrl" {
    type = "string"
    format = "uri"
    description = "URL from which the user will retrieve their compliance results."
  }
  components "schemas" "Get2TweetsFirehoseStreamLangJaResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2SpacesIdTweetsResponse" {
    type = "object"
    properties {
      data = array([components.schemas.Tweet], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "TweetDeleteComplianceSchema" {
    required = ["delete"]
    type = "object"
    properties {
      delete = components.schemas.TweetComplianceSchema
    }
  }
  components "schemas" "CreatedAt" {
    type = "string"
    format = "date-time"
    description = "Creation time of the compliance job."
    example = "2021-01-06T18:40:40.000Z"
  }
  components "schemas" "DisallowedResourceProblem" {
    description = "A problem that indicates that the resource requested violates the precepts of this API."
    allOf = [components.schemas.Problem, object({
      resource_type = string(enum("user", "tweet", "media", "list", "space")),
      section = string(enum("data", "includes")),
      resource_id = string()
    }, ["resource_id", "resource_type", "section"])]
  }
  components "schemas" "Get2LikesSample10StreamResponse" {
    type = "object"
    properties {
      data = components.schemas.Like
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "SpaceId" {
    type = "string"
    description = "The unique identifier of this Space."
    example = "1SLjjRYNejbKM"
    pattern = "^[a-zA-Z0-9]{1,13}$"
  }
  components "schemas" "Get2ComplianceJobsIdResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      data = components.schemas.ComplianceJob
    }
  }
  components "schemas" "Get2TweetsIdQuoteTweetsResponse" {
    type = "object"
    properties {
      meta = object({
        next_token = components.schemas.NextToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.Tweet], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "RulesLookupResponse" {
    type = "object"
    required = ["meta"]
    properties {
      data = array([components.schemas.Rule])
      meta = components.schemas.RulesResponseMetadata
    }
  }
  components "schemas" "UserComplianceStreamResponse" {
    oneOf = [object({
      data = components.schemas.UserComplianceData
    }, description("User compliance event."), ["data"]), object({
      errors = array([components.schemas.Problem], minItems(1))
    }, ["errors"])]
    description = "User compliance stream events."
  }
  components "schemas" "UserProfileModificationObjectSchema" {
    type = "object"
    required = ["user", "profile_field", "new_value", "event_at"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      new_value = string()
      profile_field = string()
      user = object({
        id = components.schemas.UserId
      }, ["id"])
    }
  }
  components "schemas" "Aggregate" {
    type = "integer"
    format = "int32"
    description = "The sum of results returned in this response."
  }
  components "schemas" "Get2UsersIdListMembershipsResponse" {
    type = "object"
    properties {
      data = array([components.schemas.List], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "TweetComplianceSchema" {
    type = "object"
    required = ["tweet", "event_at"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      quote_tweet_id = components.schemas.TweetId
      tweet = object({
        author_id = components.schemas.UserId,
        id = components.schemas.TweetId
      }, ["id", "author_id"])
    }
  }
  components "schemas" "ReplySettings" {
    type = "string"
    description = "Shows who can reply a Tweet. Fields returned are everyone, mentioned_users, and following."
    enum = ["everyone", "mentionedUsers", "following", "other"]
    pattern = "^[A-Za-z]{1,12}$"
  }
  components "schemas" "ResultCount" {
    type = "integer"
    format = "int32"
    description = "The number of results returned in this response."
  }
  components "schemas" "TweetCreateRequest" {
    type = "object"
    properties {
      text = components.schemas.TweetText
      card_uri = string(description("Card Uri Parameter. This is mutually exclusive from Quote Tweet Id, Poll, Media, and Direct Message Deep Link."))
      for_super_followers_only = boolean(description("Exclusive Tweet for super followers."), default(false))
      nullcast = boolean(description("Nullcasted (promoted-only) Posts do not appear in the public timeline and are not served to followers."), default(false))
      direct_message_deep_link = string(description("Link to take the conversation from the public timeline to a private Direct Message."))
      quote_tweet_id = components.schemas.TweetId
      reply_settings = string(description("Settings to indicate who can reply to the Tweet."), enum("following", "mentionedUsers", "subscribers"))
      reply {
        type = "object"
        description = "Tweet information of the Tweet being replied to."
        required = ["in_reply_to_tweet_id"]
        properties {
          exclude_reply_user_ids = array([components.schemas.UserId], description("A list of User Ids to be excluded from the reply Tweet."))
          in_reply_to_tweet_id = components.schemas.TweetId
        }
      }
      geo {
        type = "object"
        description = "Place ID being attached to the Tweet for geo location."
        properties {
          place_id = string()
        }
      }
      media {
        description = "Media information being attached to created Tweet. This is mutually exclusive from Quote Tweet Id, Poll, and Card URI."
        required = ["media_ids"]
        type = "object"
        properties {
          media_ids = array([components.schemas.MediaId], description("A list of Media Ids to be attached to a created Tweet."), maxItems(4), minItems(1))
          tagged_user_ids = array([components.schemas.UserId], description("A list of User Ids to be tagged in the media for created Tweet."), maxItems(10))
        }
      }
      poll {
        type = "object"
        description = "Poll options for a Tweet with a poll. This is mutually exclusive from Media, Quote Tweet Id, and Card URI."
        required = ["options", "duration_minutes"]
        properties {
          options = array([string(description("The text of a poll choice."), maxLength(25), minLength(1))], maxItems(4), minItems(2))
          reply_settings = string(description("Settings to indicate who can reply to the Tweet."), enum("following", "mentionedUsers"))
          duration_minutes = integer(format("int32"), description("Duration of the poll in minutes."), minimum(5), maximum(10080))
        }
      }
    }
  }
  components "schemas" "UrlFields" {
    type = "object"
    description = "Represent the portion of text recognized as a URL."
    required = ["url"]
    properties {
      status = components.schemas.HttpStatusCode
      media_key = components.schemas.MediaKey
      unwound_url = string(format("uri"), description("Fully resolved url."), example("https://twittercommunity.com/t/introducing-the-v2-follow-lookup-endpoints/147118"))
      display_url = string(description("The URL as displayed in the X client."), example("twittercommunity.com/t/introducing-…"))
      expanded_url = components.schemas.Url
      images = array([components.schemas.UrlImage], minItems(1))
      title = string(description("Title of the page the URL points to."), example("Introducing the v2 follow lookup endpoints"))
      url = components.schemas.Url
      description = string(description("Description of the URL landing page."), example("This is a description of the website."))
    }
  }
  components "schemas" "UsersLikesDeleteResponse" {
    type = "object"
    properties {
      data = object({
        liked = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "AddOrDeleteRulesRequest" {
    oneOf = [components.schemas.AddRulesRequest, components.schemas.DeleteRulesRequest]
  }
  components "schemas" "Get2UsersIdBookmarksResponse" {
    type = "object"
    properties {
      data = array([components.schemas.Tweet], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "OldestId" {
    type = "string"
    description = "The oldest id in this response."
  }
  components "schemas" "PaginationTokenLong" {
    description = "A 'long' pagination token."
    minLength = 1
    maxLength = 19
    type = "string"
  }
  components "schemas" "Trend" {
    type = "object"
    description = "A trend."
    properties {
      trend_name = string(description("Name of the trend."))
      tweet_count = integer(format("int32"), description("Number of Posts in this trend."))
    }
  }
  components "schemas" "UserScrubGeoObjectSchema" {
    type = "object"
    required = ["user", "up_to_tweet_id", "event_at"]
    properties {
      user = object({
        id = components.schemas.UserId
      }, ["id"])
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      up_to_tweet_id = components.schemas.TweetId
    }
  }
  components "schemas" "ContextAnnotationEntityFields" {
    type = "object"
    description = "Represents the data for the context annotation entity."
    required = ["id"]
    properties {
      description = string(description("Description of the context annotation entity."))
      id = string(description("The unique id for a context annotation entity."), pattern("^[0-9]{1,19}$"))
      name = string(description("Name of the context annotation entity."))
    }
  }
  components "schemas" "Get2ListsIdResponse" {
    type = "object"
    properties {
      data = components.schemas.List
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "NewestId" {
    type = "string"
    description = "The newest id in this response."
  }
  components "schemas" "Get2UsersIdTweetsResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.Tweet], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "RulesResponseMetadata" {
    type = "object"
    required = ["sent"]
    properties {
      next_token = components.schemas.NextToken
      result_count = integer(format("int32"), description("Number of Rules in result set."))
      sent = string()
      summary = components.schemas.RulesRequestSummary
    }
  }
  components "schemas" "UserScrubGeoSchema" {
    type = "object"
    required = ["scrub_geo"]
    properties {
      scrub_geo = components.schemas.UserScrubGeoObjectSchema
    }
  }
  components "schemas" "ListId" {
    type = "string"
    description = "The unique identifier of this List."
    example = "1146654567674912769"
    pattern = "^[0-9]{1,19}$"
  }
  components "schemas" "Topic" {
    type = "object"
    description = "The topic of a Space, as selected by its creator."
    required = ["id", "name"]
    properties {
      description = string(description("The description of the given topic."), example("All about technology"))
      id = components.schemas.TopicId
      name = string(description("The name of the given topic."), example("Technology"))
    }
  }
  components "schemas" "AddRulesRequest" {
    type = "object"
    description = "A request to add a user-specified stream filtering rule."
    required = ["add"]
    properties {
      add = array([components.schemas.RuleNoId])
    }
  }
  components "schemas" "ListAddUserRequest" {
    type = "object"
    required = ["user_id"]
    properties {
      user_id = components.schemas.UserId
    }
  }
  components "schemas" "ListFollowedResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      data = object({
        following = boolean()
      })
    }
  }
  components "schemas" "UsersLikesCreateRequest" {
    type = "object"
    required = ["tweet_id"]
    properties {
      tweet_id = components.schemas.TweetId
    }
  }
  components "schemas" "CreateMessageRequest" {
    anyOf = [components.schemas.CreateTextMessageRequest, components.schemas.CreateAttachmentsMessageRequest]
  }
  components "schemas" "Get2TweetsFirehoseStreamResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2UsersIdBlockingResponse" {
    type = "object"
    properties {
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "Get2ListsIdTweetsResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.Tweet], minItems(1))
    }
  }
  components "schemas" "Get2UsersIdLikedTweetsResponse" {
    type = "object"
    properties {
      data = array([components.schemas.Tweet], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken
      })
    }
  }
  components "schemas" "Get2UsersSearchResponse" {
    type = "object"
    properties {
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken
      })
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "ListPinnedRequest" {
    type = "object"
    required = ["list_id"]
    properties {
      list_id = components.schemas.ListId
    }
  }
  components "schemas" "NonCompliantRulesProblem" {
    description = "A problem that indicates the user's rule set is not compliant."
    allOf = [components.schemas.Problem]
  }
  components "schemas" "ClientAppUsage" {
    type = "object"
    description = "Usage per client app"
    properties {
      usage_result_count = integer(format("int32"), description("The number of results returned"))
      client_app_id = string(format("^[0-9]{1,19}$"), description("The unique identifier for this project"))
      usage = array([components.schemas.UsageFields], description("The usage value"), minItems(1))
    }
  }
  components "schemas" "DeleteRulesRequest" {
    type = "object"
    description = "A response from deleting user-specified stream filtering rules."
    required = ["delete"]
    properties {
      delete = object({
        ids = array([components.schemas.RuleId], description("IDs of all deleted user-specified stream filtering rules.")),
        values = array([components.schemas.RuleValue], description("Values of all deleted user-specified stream filtering rules."))
      }, description("IDs and values of all deleted user-specified stream filtering rules."))
    }
  }
  components "schemas" "EntityIndicesInclusiveExclusive" {
    type = "object"
    description = "Represent a boundary range (start and end index) for a recognized entity (for example a hashtag or a mention). `start` must be smaller than `end`.  The start index is inclusive, the end index is exclusive."
    required = ["start", "end"]
    properties {
      end = integer(description("Index (zero-based) at which position this entity ends.  The index is exclusive."), example(61))
      start = integer(description("Index (zero-based) at which position this entity starts.  The index is inclusive."), example(50))
    }
  }
  components "schemas" "UrlEntityDm" {
    description = "Represent the portion of text recognized as a URL, and its start and end position within the text."
    allOf = [components.schemas.EntityIndicesInclusiveExclusive, components.schemas.UrlFields]
  }
  components "schemas" "RuleId" {
    type = "string"
    description = "Unique identifier of this rule."
    example = "120897978112909812"
    pattern = "^[0-9]{1,19}$"
  }
  components "schemas" "RulesRequestSummary" {
    oneOf = [object({
      created = integer(format("int32"), description("Number of user-specified stream filtering rules that were created."), example(1)),
      invalid = integer(format("int32"), description("Number of invalid user-specified stream filtering rules."), example(1)),
      not_created = integer(format("int32"), description("Number of user-specified stream filtering rules that were not created."), example(1)),
      valid = integer(format("int32"), description("Number of valid user-specified stream filtering rules."), example(1))
    }, description("A summary of the results of the addition of user-specified stream filtering rules."), ["created", "not_created", "valid", "invalid"]), object({
      deleted = integer(format("int32"), description("Number of user-specified stream filtering rules that were deleted.")),
      not_deleted = integer(format("int32"), description("Number of user-specified stream filtering rules that were not deleted."))
    }, ["deleted", "not_deleted"])]
  }
  components "schemas" "TweetLabelStreamResponse" {
    oneOf = [object({
      data = components.schemas.TweetLabelData
    }, description("Tweet Label event."), ["data"]), object({
      errors = array([components.schemas.Problem], minItems(1))
    }, ["errors"])]
    description = "Tweet label stream events."
  }
  components "schemas" "Error" {
    type = "object"
    required = ["code", "message"]
    properties {
      code = integer(format("int32"))
      message = string()
    }
  }
  components "schemas" "PlaceId" {
    type = "string"
    description = "The identifier for this place."
    example = "f7eb2fa2fea288b1"
  }
  components "schemas" "UserProtectComplianceSchema" {
    type = "object"
    required = ["user_protect"]
    properties {
      user_protect = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "Geo" {
    type = "object"
    required = ["type", "bbox", "properties"]
    properties {
      bbox = array([number(format("double"), minimum(-180), maximum(180))], example(["-105.193475", "39.60973", "-105.053164", "39.761974"]), maxItems(4), minItems(4))
      geometry = components.schemas.Point
      properties = object()
      type = string(enum("Feature"))
    }
  }
  components "schemas" "Get2UsersIdPinnedListsResponse" {
    type = "object"
    properties {
      data = array([components.schemas.List], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "TweetHideResponse" {
    type = "object"
    properties {
      data = object({
        hidden = boolean()
      })
    }
  }
  components "schemas" "ComplianceJobName" {
    maxLength = 64
    type = "string"
    description = "User-provided name for a compliance job."
    example = "my-job"
  }
  components "schemas" "ComplianceJobStatus" {
    type = "string"
    description = "Status of a compliance job."
    enum = ["created", "in_progress", "failed", "complete", "expired"]
  }
  components "schemas" "UsersRetweetsCreateResponse" {
    type = "object"
    properties {
      data = object({
        id = components.schemas.TweetId,
        retweeted = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "TweetComplianceData" {
    description = "Tweet compliance data."
    oneOf = [components.schemas.TweetDeleteComplianceSchema, components.schemas.TweetWithheldComplianceSchema, components.schemas.TweetDropComplianceSchema, components.schemas.TweetUndropComplianceSchema, components.schemas.TweetEditComplianceSchema]
  }
  components "schemas" "TweetNotice" {
    type = "object"
    required = ["tweet", "event_type", "event_at", "application"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      event_type = string(description("The type of label on the Tweet"), example("misleading"))
      extended_details_url = string(description("Link to more information about this kind of label"))
      label_title = string(description("Title/header of the Tweet label"))
      tweet = object({
        id = components.schemas.TweetId,
        author_id = components.schemas.UserId
      }, ["id", "author_id"])
      application = string(description("If the label is being applied or removed. Possible values are ‘apply’ or ‘remove’."), example("apply"))
      details = string(description("Information shown on the Tweet label"))
    }
  }
  components "schemas" "HashtagEntity" {
    allOf = [components.schemas.EntityIndicesInclusiveExclusive, components.schemas.HashtagFields]
  }
  components "schemas" "ListCreateRequest" {
    type = "object"
    required = ["name"]
    properties {
      description = string(maxLength(100))
      name = string(maxLength(25), minLength(1))
      private = boolean(default(false))
    }
  }
  components "schemas" "ListFollowedRequest" {
    type = "object"
    required = ["list_id"]
    properties {
      list_id = components.schemas.ListId
    }
  }
  components "schemas" "Oauth1PermissionsProblem" {
    description = "A problem that indicates your client application does not have the required OAuth1 permissions for the requested endpoint."
    allOf = [components.schemas.Problem]
  }
  components "schemas" "Poll" {
    type = "object"
    description = "Represent a Poll attached to a Tweet."
    required = ["id", "options"]
    properties {
      end_datetime = string(format("date-time"))
      id = components.schemas.PollId
      options = array([components.schemas.PollOption], maxItems(4), minItems(2))
      voting_status = string(enum("open", "closed"))
      duration_minutes = integer(format("int32"), minimum(5), maximum(10080))
    }
  }
  components "schemas" "ClientDisconnectedProblem" {
    allOf = [components.schemas.Problem]
    description = "Your client has gone away."
  }
  components "schemas" "DmAttachments" {
    type = "array"
    description = "Attachments to a DM Event."
    items = [components.schemas.DmMediaAttachment]
  }
  components "schemas" "FilteredStreamingTweetResponse" {
    type = "object"
    description = "A Tweet or error that can be returned by the streaming Tweet API. The values returned with a successful streamed Tweet includes the user provided rules that the Tweet matched."
    properties {
      data = components.schemas.Tweet
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      matching_rules = array([object({
        id = components.schemas.RuleId,
        tag = components.schemas.RuleTag
      }, ["id"])], description("The list of rules which matched the Tweet"))
    }
  }
  components "schemas" "UsersRetweetsCreateRequest" {
    type = "object"
    required = ["tweet_id"]
    properties {
      tweet_id = components.schemas.TweetId
    }
  }
  components "schemas" "TweetId" {
    pattern = "^[0-9]{1,19}$"
    type = "string"
    description = "Unique identifier of this Tweet. This is returned as a string in order to avoid complications with languages and tools that cannot handle large integers."
    example = "1346889436626259968"
  }
  components "schemas" "UserId" {
    example = "2244994945"
    pattern = "^[0-9]{1,19}$"
    type = "string"
    description = "Unique identifier of this User. This is returned as a string in order to avoid complications with languages and tools that cannot handle large integers."
  }
  components "schemas" "UserIdMatchesAuthenticatedUser" {
    type = "string"
    description = "Unique identifier of this User. The value must be the same as the authenticated user."
    example = "2244994945"
  }
  components "schemas" "AddOrDeleteRulesResponse" {
    type = "object"
    description = "A response from modifying user-specified stream filtering rules."
    required = ["meta"]
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      meta = components.schemas.RulesResponseMetadata
      data = array([components.schemas.Rule], description("All user-specified stream filtering rules that were created."))
    }
  }
  components "schemas" "Get2UsersMeResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      data = components.schemas.User
    }
  }
  components "schemas" "TweetText" {
    type = "string"
    description = "The content of the Tweet."
    example = "Learn how to use the user Tweet timeline and user mention timeline endpoints in the X API v2 to explore Tweet\u2026 https:\/\/t.co\/56a0vZUx7i"
  }
  components "schemas" "Get2UsersIdOwnedListsResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.List], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "TweetEditComplianceSchema" {
    type = "object"
    required = ["tweet_edit"]
    properties {
      tweet_edit = components.schemas.TweetEditComplianceObjectSchema
    }
  }
  components "schemas" "UsersRetweetsDeleteResponse" {
    type = "object"
    properties {
      data = object({
        retweeted = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "ClientForbiddenProblem" {
    description = "A problem that indicates your client is forbidden from making this request."
    allOf = [components.schemas.Problem, object({
      reason = string(enum("official-client-forbidden", "client-not-enrolled")),
      registration_url = string(format("uri"))
    })]
  }
  components "schemas" "GenericProblem" {
    description = "A generic problem with no additional information beyond that provided by the HTTP status code."
    allOf = [components.schemas.Problem]
  }
  components "schemas" "Get2TweetsSampleStreamResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "TweetLabelData" {
    description = "Tweet label data."
    oneOf = [components.schemas.TweetNoticeSchema, components.schemas.TweetUnviewableSchema]
  }
  components "schemas" "UploadExpiration" {
    type = "string"
    format = "date-time"
    description = "Expiration time of the upload URL."
    example = "2021-01-06T18:40:40.000Z"
  }
  components "schemas" "Get2TweetsSearchStreamRulesCountsResponse" {
    type = "object"
    properties {
      data = components.schemas.RulesCount
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "Get2UsersIdFollowedListsResponse" {
    type = "object"
    properties {
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.List], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "HttpStatusCode" {
    minimum = 100
    maximum = 599
    type = "integer"
    description = "HTTP Status Code."
  }
  components "schemas" "Place" {
    type = "object"
    required = ["id", "full_name"]
    properties {
      contained_within = array([components.schemas.PlaceId], minItems(1))
      country = string(description("The full name of the county in which this place exists."), example("United States"))
      country_code = components.schemas.CountryCode
      full_name = string(description("The full name of this place."), example("Lakewood, CO"))
      geo = components.schemas.Geo
      id = components.schemas.PlaceId
      name = string(description("The human readable name of this place."), example("Lakewood"))
      place_type = components.schemas.PlaceType
    }
  }
  components "schemas" "ResourceUnavailableProblem" {
    allOf = [components.schemas.Problem, object({
      parameter = string(minLength(1)),
      resource_id = string(),
      resource_type = string(enum("user", "tweet", "media", "list", "space"))
    }, ["parameter", "resource_id", "resource_type"])]
    description = "A problem that indicates a particular Tweet, User, etc. is not available to you."
  }
  components "schemas" "UnlikeComplianceSchema" {
    type = "object"
    required = ["favorite", "event_at"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      favorite = object({
        id = components.schemas.TweetId,
        user_id = components.schemas.UserId
      }, ["id", "user_id"])
    }
  }
  components "schemas" "Usage" {
    type = "object"
    description = "Usage per client app"
    properties {
      project_cap = integer(format("int32"), description("Total number of Posts that can be read in this project per month"))
      project_id = string(format("^[0-9]{1,19}$"), description("The unique identifier for this project"))
      project_usage = integer(format("int32"), description("The number of Posts read in this project"))
      cap_reset_day = integer(format("int32"), description("Number of days left for the Tweet cap to reset"))
      daily_client_app_usage = array([components.schemas.ClientAppUsage], description("The daily usage breakdown for each Client Application a project"), minItems(1))
      daily_project_usage = object({
        project_id = integer(format("int32"), description("The unique identifier for this project")),
        usage = array([components.schemas.UsageFields], description("The usage value"), minItems(1))
      }, description("The daily usage breakdown for a project"))
    }
  }
  components "schemas" "Get2SpacesSearchResponse" {
    type = "object"
    properties {
      data = array([components.schemas.Space], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "LikeComplianceSchema" {
    type = "object"
    required = ["delete"]
    properties {
      delete = components.schemas.UnlikeComplianceSchema
    }
  }
  components "schemas" "MediaHeight" {
    type = "integer"
    description = "The height of the media in pixels."
  }
  components "schemas" "TweetWithheld" {
    type = "object"
    description = "Indicates withholding details for [withheld content](https://help.twitter.com/en/rules-and-policies/tweet-withheld-by-country)."
    required = ["copyright", "country_codes"]
    properties {
      copyright = boolean(description("Indicates if the content is being withheld for on the basis of copyright infringement."))
      country_codes = array([components.schemas.CountryCode], description("Provides a list of countries where this content is not available."), minItems(1), uniqueItems(true))
      scope = string(description("Indicates whether the content being withheld is the `tweet` or a `user`."), enum("tweet", "user"))
    }
  }
  components "schemas" "Get2DmEventsResponse" {
    type = "object"
    properties {
      data = array([components.schemas.DmEvent], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "Get2UsersResponse" {
    type = "object"
    properties {
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "MediaKey" {
    type = "string"
    description = "The Media Key identifier for this attachment."
    pattern = "^([0-9]+)_([0-9]+)$"
  }
  components "schemas" "Variant" {
    type = "object"
    properties {
      bit_rate = integer(description("The bit rate of the media."))
      content_type = string(description("The content type of the media."))
      url = string(format("uri"), description("The url to the media."))
    }
  }
  components "schemas" "Variants" {
    description = "An array of all available variants of the media."
    items = [components.schemas.Variant]
    type = "array"
  }
  components "schemas" "BookmarkAddRequest" {
    type = "object"
    required = ["tweet_id"]
    properties {
      tweet_id = components.schemas.TweetId
    }
  }
  components "schemas" "Get2SpacesResponse" {
    type = "object"
    properties {
      data = array([components.schemas.Space], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "User" {
    type = "object"
    description = "The X User object."
    example = {
      name = "X Dev",
      protected = "false",
      username = "TwitterDev",
      created_at = "2013-12-14T04:35:55Z",
      id = "2244994945"
    }
    required = ["id", "name", "username"]
    properties {
      verified = boolean(description("Indicate if this User is a verified X User."))
      url = string(description("The URL specified in the User's profile."))
      most_recent_tweet_id = components.schemas.TweetId
      created_at = string(format("date-time"), description("Creation time of this User."))
      name = string(description("The friendly name of this User, as shown on their profile."))
      receives_your_dm = boolean(description("Indicates if you can send a DM to this User"))
      pinned_tweet_id = components.schemas.TweetId
      entities = object({
        description = components.schemas.FullTextEntities,
        url = object({
          urls = array([components.schemas.UrlEntity], minItems(1))
        }, description("Expanded details for the URL specified in the User's profile, with start and end indices."))
      }, description("A list of metadata found in the User's profile description."))
      public_metrics = object({
        listed_count = integer(description("The number of lists that include this User.")),
        tweet_count = integer(description("The number of Posts (including Retweets) posted by this User.")),
        followers_count = integer(description("Number of Users who are following this User.")),
        following_count = integer(description("Number of Users this User is following.")),
        like_count = integer(description("The number of likes created by this User."))
      }, description("A list of metrics for this User."), ["followers_count", "following_count", "tweet_count", "listed_count"])
      id = components.schemas.UserId
      username = components.schemas.UserName
      connection_status = array([string(description("Type of connection between users."), enum("follow_request_received", "follow_request_sent", "blocking", "followed_by", "following", "muting"))], description("Returns detailed information about the relationship between two users."))
      subscription_type = string(description("The X Blue subscription type of the user, eg: Basic, Premium, PremiumPlus or None."), enum("Basic", "Premium", "PremiumPlus", "None"))
      description = string(description("The text of this User's profile description (also known as bio), if the User provided one."))
      profile_image_url = string(format("uri"), description("The URL to the profile image for this User."))
      verified_type = string(description("The X Blue verified type of the user, eg: blue, government, business or none."), enum("blue", "government", "business", "none"))
      protected = boolean(description("Indicates if this User has chosen to protect their Posts (in other words, if this User's Posts are private)."))
      withheld = components.schemas.UserWithheld
      location = string(description("The location specified in the User's profile, if the User provided one. As this is a freeform value, it may not indicate a valid location, but it may be fuzzily evaluated when performing searches with location queries."))
    }
  }
  components "schemas" "DownloadExpiration" {
    type = "string"
    format = "date-time"
    description = "Expiration time of the download URL."
    example = "2021-01-06T18:40:40.000Z"
  }
  components "schemas" "MuteUserRequest" {
    type = "object"
    required = ["target_user_id"]
    properties {
      target_user_id = components.schemas.UserId
    }
  }
  components "schemas" "SearchCount" {
    required = ["end", "start", "tweet_count"]
    type = "object"
    description = "Represent a Search Count Result."
    properties {
      end = components.schemas.End
      start = components.schemas.Start
      tweet_count = components.schemas.TweetCount
    }
  }
  components "schemas" "Like" {
    type = "object"
    description = "A Like event, with the liking user and the tweet being liked"
    properties {
      liking_user_id = components.schemas.UserId
      timestamp_ms = integer(format("int32"), description("Timestamp in milliseconds of creation."))
      created_at = string(format("date-time"), description("Creation time of the Tweet."), example("2021-01-06T18:40:40.000Z"))
      id = components.schemas.LikeId
      liked_tweet_id = components.schemas.TweetId
    }
  }
  components "schemas" "ListPinnedResponse" {
    type = "object"
    properties {
      data = object({
        pinned = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "ListUnpinResponse" {
    type = "object"
    properties {
      data = object({
        pinned = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "UserUnsuspendComplianceSchema" {
    type = "object"
    required = ["user_unsuspend"]
    properties {
      user_unsuspend = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "ComplianceJob" {
    type = "object"
    required = ["id", "type", "created_at", "upload_url", "download_url", "upload_expires_at", "download_expires_at", "status"]
    properties {
      status = components.schemas.ComplianceJobStatus
      created_at = components.schemas.CreatedAt
      upload_url = components.schemas.UploadUrl
      download_expires_at = components.schemas.DownloadExpiration
      download_url = components.schemas.DownloadUrl
      name = components.schemas.ComplianceJobName
      upload_expires_at = components.schemas.UploadExpiration
      id = components.schemas.JobId
      type = components.schemas.ComplianceJobType
    }
  }
  components "schemas" "CreateDmConversationRequest" {
    type = "object"
    required = ["conversation_type", "participant_ids", "message"]
    properties {
      message = components.schemas.CreateMessageRequest
      participant_ids = components.schemas.DmParticipants
      conversation_type = string(description("The conversation type that is being created."), enum("Group"))
    }
  }
  components "schemas" "Get2TweetsFirehoseStreamLangEnResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
    }
  }
  components "schemas" "ReplySettingsWithVerifiedUsers" {
    pattern = "^[A-Za-z]{1,12}$"
    type = "string"
    description = "Shows who can reply a Tweet. Fields returned are everyone, mentioned_users, subscribers, verified and following."
    enum = ["everyone", "mentionedUsers", "following", "other", "subscribers", "verified"]
  }
  components "schemas" "DmMediaAttachment" {
    type = "object"
    required = ["media_id"]
    properties {
      media_id = components.schemas.MediaId
    }
  }
  components "schemas" "Get2SpacesByCreatorIdsResponse" {
    type = "object"
    properties {
      data = array([components.schemas.Space], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "NextToken" {
    type = "string"
    description = "The next token."
    minLength = 1
  }
  components "schemas" "ListUpdateRequest" {
    type = "object"
    properties {
      description = string(maxLength(100))
      name = string(maxLength(25), minLength(1))
      private = boolean()
    }
  }
  components "schemas" "Position" {
    type = "array"
    description = "A [GeoJson Position](https://tools.ietf.org/html/rfc7946#section-3.1.1) in the format `[longitude,latitude]`."
    example = ["-105.18816086351444", "40.247749999999996"]
    minItems = 2
    maxItems = 2
    items = [number()]
  }
  components "schemas" "TweetComplianceStreamResponse" {
    description = "Tweet compliance stream events."
    oneOf = [object({
      data = components.schemas.TweetComplianceData
    }, description("Compliance event."), ["data"]), object({
      errors = array([components.schemas.Problem], minItems(1))
    }, ["errors"])]
  }
  components "schemas" "TweetUnviewable" {
    type = "object"
    required = ["tweet", "event_at", "application"]
    properties {
      tweet = object({
        author_id = components.schemas.UserId,
        id = components.schemas.TweetId
      }, ["id", "author_id"])
      application = string(description("If the label is being applied or removed. Possible values are ‘apply’ or ‘remove’."), example("apply"))
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
    }
  }
  components "schemas" "ContextAnnotation" {
    type = "object"
    description = "Annotation inferred from the Tweet text."
    required = ["domain", "entity"]
    properties {
      domain = components.schemas.ContextAnnotationDomainFields
      entity = components.schemas.ContextAnnotationEntityFields
    }
  }
  components "schemas" "Get2UsersIdFollowingResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.User], minItems(1))
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "HashtagFields" {
    type = "object"
    description = "Represent the portion of text recognized as a Hashtag, and its start and end position within the text."
    required = ["tag"]
    properties {
      tag = string(description("The text of the Hashtag."), example("MondayMotivation"))
    }
  }
  components "schemas" "PlaceType" {
    type = "string"
    example = "city"
    enum = ["poi", "neighborhood", "city", "admin", "country", "unknown"]
  }
  components "schemas" "RuleTag" {
    type = "string"
    description = "A tag meant for the labeling of user provided rules."
    example = "Non-retweeted coffee Posts"
  }
  components "schemas" "DmConversationId" {
    type = "string"
    description = "Unique identifier of a DM conversation. This can either be a numeric string, or a pair of numeric strings separated by a '-' character in the case of one-on-one DM Conversations."
    example = "123123123-456456456"
    pattern = "^([0-9]{1,19}-[0-9]{1,19}|[0-9]{15,19})$"
  }
  components "schemas" "Get2LikesFirehoseStreamResponse" {
    type = "object"
    properties {
      data = components.schemas.Like
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2UsersByUsernameUsernameResponse" {
    type = "object"
    properties {
      data = components.schemas.User
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "CashtagFields" {
    type = "object"
    description = "Represent the portion of text recognized as a Cashtag, and its start and end position within the text."
    required = ["tag"]
    properties {
      tag = string(example("TWTR"))
    }
  }
  components "schemas" "ConnectionExceptionProblem" {
    description = "A problem that indicates something is wrong with the connection."
    allOf = [components.schemas.Problem, object({
      connection_issue = string(enum("TooManyConnections", "ProvisioningSubscription", "RuleConfigurationIssue", "RulesInvalidIssue"))
    })]
  }
  components "schemas" "UserComplianceSchema" {
    type = "object"
    required = ["user", "event_at"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      user = object({
        id = components.schemas.UserId
      }, ["id"])
    }
  }
  components "schemas" "Get2DmConversationsWithParticipantIdDmEventsResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array([components.schemas.DmEvent], minItems(1))
    }
  }
  components "schemas" "RuleNoId" {
    type = "object"
    description = "A user-provided stream filtering rule."
    required = ["value"]
    properties {
      tag = components.schemas.RuleTag
      value = components.schemas.RuleValue
    }
  }
  components "schemas" "Url" {
    format = "uri"
    description = "A validly formatted URL."
    example = "https://developer.twitter.com/en/docs/twitter-api"
    type = "string"
  }
  components "schemas" "Expansions" {
    type = "object"
    properties {
      places = array([components.schemas.Place], minItems(1))
      polls = array([components.schemas.Poll], minItems(1))
      topics = array([components.schemas.Topic], minItems(1))
      tweets = array([components.schemas.Tweet], minItems(1))
      users = array([components.schemas.User], minItems(1))
      media = array([components.schemas.Media], minItems(1))
    }
  }
  components "schemas" "Rule" {
    description = "A user-provided stream filtering rule."
    required = ["value"]
    type = "object"
    properties {
      id = components.schemas.RuleId
      tag = components.schemas.RuleTag
      value = components.schemas.RuleValue
    }
  }
  components "schemas" "AllProjectClientApps" {
    type = "array"
    description = "Client App Rule Counts for all applications in the project"
    items = [components.schemas.AppRulesCount]
  }
  components "schemas" "CreateDmEventResponse" {
    type = "object"
    properties {
      errors = array([components.schemas.Problem], minItems(1))
      data = object({
        dm_conversation_id = components.schemas.DmConversationId,
        dm_event_id = components.schemas.DmEventId
      }, ["dm_conversation_id", "dm_event_id"])
    }
  }
  components "schemas" "LikeId" {
    type = "string"
    description = "The unique identifier of this Like."
    example = "8ba4f34e6235d905a46bac021d98e923"
    pattern = "^[A-Za-z0-9_]{1,40}$"
  }
  components "schemas" "UsersFollowingCreateResponse" {
    type = "object"
    properties {
      data = object({
        following = boolean(),
        pending_follow = boolean()
      })
      errors = array([components.schemas.Problem], minItems(1))
    }
  }
  components "schemas" "FieldUnauthorizedProblem" {
    description = "A problem that indicates that you are not allowed to see a particular field on a Tweet, User, etc."
    allOf = [components.schemas.Problem, object({
      field = string(),
      resource_type = string(enum("user", "tweet", "media", "list", "space")),
      section = string(enum("data", "includes"))
    }, ["resource_type", "field", "section"])]
  }
  components "schemas" "Get2TweetsIdResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array([components.schemas.Problem], minItems(1))
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "UsageCapExceededProblem" {
    allOf = [components.schemas.Problem, object({
      period = string(enum("Daily", "Monthly")),
      scope = string(enum("Account", "Product"))
    })]
    description = "A problem that indicates that a usage cap has been exceeded."
  }
  components "parameters" "PollFieldsParameter" {
    name = "poll.fields"
    in = "query"
    description = "A comma separated list of Poll fields to display."
    style = "form"
    schema = array([string(enum("duration_minutes", "end_datetime", "id", "options", "voting_status"))], description("The fields available for a Poll object."), example(["duration_minutes", "end_datetime", "id", "options", "voting_status"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "TrendFieldsParameter" {
    description = "A comma separated list of Trend fields to display."
    schema = array([string(enum("trend_name", "tweet_count"))], description("The fields available for a Trend object."), example(["trend_name", "tweet_count"]), minItems(1), uniqueItems(true))
    style = "form"
    name = "trend.fields"
    in = "query"
  }
  components "parameters" "UserFieldsParameter" {
    name = "user.fields"
    in = "query"
    description = "A comma separated list of User fields to display."
    style = "form"
    schema = array([string(enum("connection_status", "created_at", "description", "entities", "id", "location", "most_recent_tweet_id", "name", "pinned_tweet_id", "profile_image_url", "protected", "public_metrics", "receives_your_dm", "subscription_type", "url", "username", "verified", "verified_type", "withheld"))], description("The fields available for a User object."), example(["connection_status", "created_at", "description", "entities", "id", "location", "most_recent_tweet_id", "name", "pinned_tweet_id", "profile_image_url", "protected", "public_metrics", "receives_your_dm", "subscription_type", "url", "username", "verified", "verified_type", "withheld"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "DmEventFieldsParameter" {
    style = "form"
    name = "dm_event.fields"
    in = "query"
    schema = array([string(enum("attachments", "created_at", "dm_conversation_id", "entities", "event_type", "id", "participant_ids", "referenced_tweets", "sender_id", "text"))], description("The fields available for a DmEvent object."), example(["attachments", "created_at", "dm_conversation_id", "entities", "event_type", "id", "participant_ids", "referenced_tweets", "sender_id", "text"]), minItems(1), uniqueItems(true))
    description = "A comma separated list of DmEvent fields to display."
  }
  components "parameters" "TopicFieldsParameter" {
    schema = array([string(enum("description", "id", "name"))], description("The fields available for a Topic object."), example(["description", "id", "name"]), minItems(1), uniqueItems(true))
    name = "topic.fields"
    in = "query"
    description = "A comma separated list of Topic fields to display."
    style = "form"
  }
  components "parameters" "DmEventExpansionsParameter" {
    style = "form"
    schema = array([string(enum("attachments.media_keys", "participant_ids", "referenced_tweets.id", "sender_id"))], description("The list of fields you can expand for a [DmEvent](#DmEvent) object. If the field has an ID, it can be expanded into a full object."), example(["attachments.media_keys", "participant_ids", "referenced_tweets.id", "sender_id"]), minItems(1), uniqueItems(true))
    name = "expansions"
    in = "query"
    description = "A comma separated list of fields to expand."
  }
  components "parameters" "ListExpansionsParameter" {
    in = "query"
    description = "A comma separated list of fields to expand."
    schema = array([string(enum("owner_id"))], description("The list of fields you can expand for a [List](#List) object. If the field has an ID, it can be expanded into a full object."), example(["owner_id"]), minItems(1), uniqueItems(true))
    style = "form"
    name = "expansions"
  }
  components "parameters" "ListFieldsParameter" {
    name = "list.fields"
    in = "query"
    description = "A comma separated list of List fields to display."
    style = "form"
    schema = array([string(enum("created_at", "description", "follower_count", "id", "member_count", "name", "owner_id", "private"))], description("The fields available for a List object."), example(["created_at", "description", "follower_count", "id", "member_count", "name", "owner_id", "private"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "MediaFieldsParameter" {
    in = "query"
    description = "A comma separated list of Media fields to display."
    style = "form"
    name = "media.fields"
    schema = array([string(enum("alt_text", "duration_ms", "height", "media_key", "non_public_metrics", "organic_metrics", "preview_image_url", "promoted_metrics", "public_metrics", "type", "url", "variants", "width"))], description("The fields available for a Media object."), example(["alt_text", "duration_ms", "height", "media_key", "non_public_metrics", "organic_metrics", "preview_image_url", "promoted_metrics", "public_metrics", "type", "url", "variants", "width"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "LikeExpansionsParameter" {
    name = "expansions"
    in = "query"
    description = "A comma separated list of fields to expand."
    style = "form"
    schema = array([string(enum("liked_tweet_id", "liking_user_id"))], description("The list of fields you can expand for a [Like](#Like) object. If the field has an ID, it can be expanded into a full object."), example(["liked_tweet_id", "liking_user_id"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "LikeFieldsParameter" {
    in = "query"
    description = "A comma separated list of Like fields to display."
    style = "form"
    schema = array([string(enum("created_at", "id", "liked_tweet_id", "liking_user_id", "timestamp_ms"))], description("The fields available for a Like object."), example(["created_at", "id", "liked_tweet_id", "liking_user_id", "timestamp_ms"]), minItems(1), uniqueItems(true))
    name = "like.fields"
  }
  components "parameters" "UserExpansionsParameter" {
    style = "form"
    schema = array([string(enum("most_recent_tweet_id", "pinned_tweet_id"))], description("The list of fields you can expand for a [User](#User) object. If the field has an ID, it can be expanded into a full object."), example(["most_recent_tweet_id", "pinned_tweet_id"]), minItems(1), uniqueItems(true))
    name = "expansions"
    in = "query"
    description = "A comma separated list of fields to expand."
  }
  components "parameters" "SearchCountFieldsParameter" {
    name = "search_count.fields"
    in = "query"
    description = "A comma separated list of SearchCount fields to display."
    style = "form"
    schema = array([string(enum("end", "start", "tweet_count"))], description("The fields available for a SearchCount object."), example(["end", "start", "tweet_count"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "TweetFieldsParameter" {
    schema = array([string(enum("attachments", "author_id", "card_uri", "context_annotations", "conversation_id", "created_at", "edit_controls", "edit_history_tweet_ids", "entities", "geo", "id", "in_reply_to_user_id", "lang", "non_public_metrics", "note_tweet", "organic_metrics", "possibly_sensitive", "promoted_metrics", "public_metrics", "referenced_tweets", "reply_settings", "scopes", "source", "text", "withheld"))], description("The fields available for a Tweet object."), example(["attachments", "author_id", "card_uri", "context_annotations", "conversation_id", "created_at", "edit_controls", "edit_history_tweet_ids", "entities", "geo", "id", "in_reply_to_user_id", "lang", "non_public_metrics", "note_tweet", "organic_metrics", "possibly_sensitive", "promoted_metrics", "public_metrics", "referenced_tweets", "reply_settings", "scopes", "source", "text", "withheld"]), minItems(1), uniqueItems(true))
    style = "form"
    name = "tweet.fields"
    in = "query"
    description = "A comma separated list of Tweet fields to display."
  }
  components "parameters" "UsageFieldsParameter" {
    schema = array([string(enum("cap_reset_day", "daily_client_app_usage", "daily_project_usage", "project_cap", "project_id", "project_usage"))], description("The fields available for a Usage object."), example(["cap_reset_day", "daily_client_app_usage", "daily_project_usage", "project_cap", "project_id", "project_usage"]), minItems(1), uniqueItems(true))
    name = "usage.fields"
    in = "query"
    description = "A comma separated list of Usage fields to display."
    style = "form"
  }
  components "parameters" "PlaceFieldsParameter" {
    description = "A comma separated list of Place fields to display."
    style = "form"
    name = "place.fields"
    in = "query"
    schema = array([string(enum("contained_within", "country", "country_code", "full_name", "geo", "id", "name", "place_type"))], description("The fields available for a Place object."), example(["contained_within", "country", "country_code", "full_name", "geo", "id", "name", "place_type"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "DmConversationFieldsParameter" {
    name = "dm_conversation.fields"
    in = "query"
    description = "A comma separated list of DmConversation fields to display."
    style = "form"
    schema = array([string(enum("id"))], description("The fields available for a DmConversation object."), example(["id"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "RulesCountFieldsParameter" {
    name = "rules_count.fields"
    in = "query"
    schema = array([string(enum("all_project_client_apps", "cap_per_client_app", "cap_per_project", "client_app_rules_count", "project_rules_count"))], description("The fields available for a RulesCount object."), example(["all_project_client_apps", "cap_per_client_app", "cap_per_project", "client_app_rules_count", "project_rules_count"]), minItems(1), uniqueItems(true))
    description = "A comma separated list of RulesCount fields to display."
    style = "form"
  }
  components "parameters" "SpaceFieldsParameter" {
    schema = array([string(enum("created_at", "creator_id", "ended_at", "host_ids", "id", "invited_user_ids", "is_ticketed", "lang", "participant_count", "scheduled_start", "speaker_ids", "started_at", "state", "subscriber_count", "title", "topic_ids", "updated_at"))], description("The fields available for a Space object."), example(["created_at", "creator_id", "ended_at", "host_ids", "id", "invited_user_ids", "is_ticketed", "lang", "participant_count", "scheduled_start", "speaker_ids", "started_at", "state", "subscriber_count", "title", "topic_ids", "updated_at"]), minItems(1), uniqueItems(true))
    name = "space.fields"
    in = "query"
    description = "A comma separated list of Space fields to display."
    style = "form"
  }
  components "parameters" "TweetExpansionsParameter" {
    name = "expansions"
    in = "query"
    description = "A comma separated list of fields to expand."
    style = "form"
    schema = array([string(enum("attachments.media_keys", "attachments.media_source_tweet", "attachments.poll_ids", "author_id", "edit_history_tweet_ids", "entities.mentions.username", "geo.place_id", "in_reply_to_user_id", "entities.note.mentions.username", "referenced_tweets.id", "referenced_tweets.id.author_id"))], description("The list of fields you can expand for a [Tweet](#Tweet) object. If the field has an ID, it can be expanded into a full object."), example(["attachments.media_keys", "attachments.media_source_tweet", "attachments.poll_ids", "author_id", "edit_history_tweet_ids", "entities.mentions.username", "geo.place_id", "in_reply_to_user_id", "entities.note.mentions.username", "referenced_tweets.id", "referenced_tweets.id.author_id"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "ComplianceJobFieldsParameter" {
    name = "compliance_job.fields"
    in = "query"
    description = "A comma separated list of ComplianceJob fields to display."
    style = "form"
    schema = array([string(enum("created_at", "download_expires_at", "download_url", "id", "name", "resumable", "status", "type", "upload_expires_at", "upload_url"))], description("The fields available for a ComplianceJob object."), example(["created_at", "download_expires_at", "download_url", "id", "name", "resumable", "status", "type", "upload_expires_at", "upload_url"]), minItems(1), uniqueItems(true))
  }
  components "parameters" "SpaceExpansionsParameter" {
    description = "A comma separated list of fields to expand."
    schema = array([string(enum("creator_id", "host_ids", "invited_user_ids", "speaker_ids", "topic_ids"))], description("The list of fields you can expand for a [Space](#Space) object. If the field has an ID, it can be expanded into a full object."), example(["creator_id", "host_ids", "invited_user_ids", "speaker_ids", "topic_ids"]), minItems(1), uniqueItems(true))
    style = "form"
    name = "expansions"
    in = "query"
  }
  components "securityScheme" "UserToken" {
    scheme = "OAuth"
    type = "http"
  }
  components "securityScheme" "BearerToken" {
    scheme = "bearer"
    type = "http"
  }
  components "securityScheme" "OAuth2UserToken" {
    type = "oauth2"
    flows {
      authorizationCode {
        tokenUrl = "https://api.twitter.com/2/oauth2/token"
        authorizationUrl = "https://api.twitter.com/2/oauth2/authorize"
        scopes {
          list.write = "Create and manage Lists for you."
          block.read = "Accounts you’ve blocked."
          like.write = "Like and un-like Tweets for you."
          dm.read = "All your Direct Messages"
          like.read = "Tweets you’ve liked and likes you can view."
          tweet.moderate.write = "Hide and unhide replies to your Tweets."
          follows.read = "People who follow you and people who you follow."
          tweet.read = "All the Tweets you can see, including Tweets from protected accounts."
          offline.access = "App can request refresh token."
          follows.write = "Follow and unfollow people for you."
          mute.write = "Mute and unmute accounts for you."
          tweet.write = "Tweet and retweet for you."
          bookmark.write = "Allows an app to create and delete bookmarks"
          dm.write = "Send and manage Direct Messages for you"
          mute.read = "Accounts you’ve muted."
          bookmark.read = "Allows an app to read bookmarked Tweets"
          space.read = "Access all of the Spaces you can see."
          users.read = "Any account you can see, including protected accounts. Any account you can see, including protected accounts."
          list.read = "Lists, list members, and list followers of lists you’ve created or are a member of, including private lists."
        }
      }
    }
  }
