
  openapi = "3.0.0"
  servers = [{
    url = "https://api.twitter.com",
    description = "Twitter API"
  }]
  tags = [{
    description = "Endpoints related to retrieving, managing bookmarks of a user",
    name = "Bookmarks",
    externalDocs = {
      url = "https://developer.twitter.com/en/docs/twitter-api/bookmarks",
      description = "Find out more"
    }
  }, {
    name = "Compliance",
    description = "Endpoints related to keeping X data in your systems compliant",
    externalDocs = {
      url = "https://developer.twitter.com/en/docs/twitter-api/compliance/batch-tweet/introduction",
      description = "Find out more"
    }
  }, {
    description = "Endpoints related to retrieving, managing Direct Messages",
    name = "Direct Messages",
    externalDocs = {
      url = "https://developer.twitter.com/en/docs/twitter-api/direct-messages",
      description = "Find out more"
    }
  }, {
    name = "General",
    description = "Miscellaneous endpoints for general API functionality",
    externalDocs = {
      description = "Find out more",
      url = "https://developer.twitter.com/en/docs/twitter-api"
    }
  }, {
    name = "Lists",
    description = "Endpoints related to retrieving, managing Lists",
    externalDocs = {
      description = "Find out more",
      url = "https://developer.twitter.com/en/docs/twitter-api/lists"
    }
  }, {
    description = "Endpoints related to retrieving, managing Spaces",
    name = "Spaces",
    externalDocs = {
      url = "https://developer.twitter.com/en/docs/twitter-api/spaces",
      description = "Find out more"
    }
  }, {
    description = "Endpoints related to retrieving, searching, and modifying Tweets",
    name = "Tweets",
    externalDocs = {
      url = "https://developer.twitter.com/en/docs/twitter-api/tweets/lookup",
      description = "Find out more"
    }
  }, {
    name = "Users",
    description = "Endpoints related to retrieving, managing relationships of Users",
    externalDocs = {
      url = "https://developer.twitter.com/en/docs/twitter-api/users/lookup",
      description = "Find out more"
    }
  }]
  info {
    termsOfService = "https://developer.twitter.com/en/developer-terms/agreement-and-policy.html"
    version = "2.98"
    title = "Twitter API v2"
    description = "Twitter API v2 available endpoints"
    contact {
      name = "Twitter Developers"
      url = "https://developer.twitter.com/"
    }
    license {
      name = "Twitter Developer Agreement and Policy"
      url = "https://developer.twitter.com/en/developer-terms/agreement-and-policy.html"
    }
  }
  paths "/2/dm_conversations/{dm_conversation_id}/messages" "post" {
    tags = ["Direct Messages"]
    security = [{
      OAuth2UserToken = ["dm.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Send a new message to a DM Conversation"
    description = "Creates a new message for a DM Conversation specified by DM Conversation ID"
    operationId = "dmConversationByIdEventIdCreate"
    parameters "dm_conversation_id" {
      required = true
      in = "path"
      description = "The DM Conversation ID."
      style = "simple"
      schema = string()
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
      style = "simple"
      in = "path"
      description = "The ID of the List."
      schema = components.schemas.ListId
    }
    parameters "max_results" {
      description = "The maximum number of results."
      style = "form"
      in = "query"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
    }
    parameters "pagination_token" {
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      in = "query"
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
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/lists/{id}/members" "post" {
    description = "Causes a User to become a member of a List."
    operationId = "listAddMember"
    summary = "Add a List member"
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      in = "path"
      description = "The ID of the List for which to add a member."
      style = "simple"
      schema = components.schemas.ListId
      required = true
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
  paths "/2/tweets/search/stream" "get" {
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    operationId = "searchStream"
    summary = "Filtered stream"
    description = "Streams Posts matching the stream's active rule set."
    parameters "backfill_minutes" {
      style = "form"
      in = "query"
      description = "The number of minutes of backfill requested."
      schema = integer(format("int32"), maximum(5))
    }
    parameters "start_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Posts will be provided."
      style = "form"
      example = "2021-02-01T18:40:40.000Z"
      schema = string(format("date-time"))
      in = "query"
    }
    parameters "end_time" {
      style = "form"
      in = "query"
      example = "2021-02-14T18:40:40.000Z"
      schema = string(format("date-time"))
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
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
  paths "/2/tweets/search/stream/rules/counts" "get" {
    summary = "Rules Count"
    description = "Returns the counts of rules from a User's active rule set, to reflect usage by project and application."
    operationId = "getRuleCount"
    tags = ["General"]
    parameters = [components.parameters.RulesCountFieldsParameter]
    security = [{
      BearerToken = []
    }]
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
        schema = components.schemas.Get2TweetsSearchStreamRulesCountsResponse
      }
    }
  }
  paths "/2/users" "get" {
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "User lookup by IDs"
    description = "This endpoint returns information about Users. Specify Users by their ID."
    operationId = "findUsersById"
    tags = ["Users"]
    parameters "ids" {
      schema = array(maxItems(100), minItems(1), [components.schemas.UserId])
      required = true
      in = "query"
      description = "A list of User IDs, comma-separated. You can specify up to 100 IDs."
      style = "form"
      example = "2244994945,6253282,12"
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
  paths "/2/users/{id}/blocking" "get" {
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["block.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Returns User objects that are blocked by provided User ID"
    description = "Returns a list of Users that are blocked by the provided User ID"
    operationId = "usersIdBlocking"
    tags = ["Users"]
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
      schema = integer(format("int32"), minimum(1), maximum(1000))
    }
    parameters "pagination_token" {
      style = "form"
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      schema = components.schemas.PaginationToken32
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdBlockingResponse
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
  paths "/2/users/{id}/likes" "post" {
    description = "Causes the User (in the path) to like the specified Post. The User in the path must match the User context authorizing the request."
    operationId = "usersIdLike"
    summary = "Causes the User (in the path) to like the specified Post"
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["like.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User that is requesting to like the Post."
      style = "simple"
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.UsersLikesCreateRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UsersLikesCreateResponse
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
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    description = "Returns Spaces that match the provided query."
    operationId = "searchSpaces"
    summary = "Search for Spaces"
    tags = ["Spaces"]
    parameters = [components.parameters.SpaceFieldsParameter, components.parameters.SpaceExpansionsParameter, components.parameters.UserFieldsParameter, components.parameters.TopicFieldsParameter]
    parameters "query" {
      in = "query"
      description = "The search query."
      style = "form"
      example = "crypto"
      schema = string(example("crypto"), maxLength(2048), minLength(1))
      required = true
    }
    parameters "state" {
      description = "The state of Spaces to search for."
      style = "form"
      schema = string(default("all"), enum("live", "scheduled", "all"))
      in = "query"
    }
    parameters "max_results" {
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
      in = "query"
      description = "The number of results to return."
      style = "form"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2SpacesSearchResponse
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
  paths "/2/tweets/firehose/stream/lang/pt" "get" {
    summary = "Portuguese Language Firehose stream"
    description = "Streams 100% of Portuguese Language public Posts."
    operationId = "getTweetsFirehoseStreamLangPt"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
    }
    parameters "partition" {
      description = "The partition number."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(2))
      required = true
      in = "query"
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = "2021-02-14T18:40:40.000Z"
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      example = "2021-02-14T18:40:40.000Z"
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
  paths "/2/tweets/search/all" "get" {
    security = [{
      BearerToken = []
    }]
    summary = "Full-archive search"
    description = "Returns Posts that match a search query."
    operationId = "tweetsFullarchiveSearch"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    parameters "query" {
      required = true
      in = "query"
      description = "One query/rule/filter for matching Posts. Refer to https://t.co/rulelength to identify the max query length."
      style = "form"
      schema = string(example("(from:TwitterDev OR from:TwitterAPI) has:media -is:retweet"), maxLength(4096), minLength(1))
    }
    parameters "start_time" {
      style = "form"
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The oldest UTC timestamp from which the Posts will be provided. Timestamp is in second granularity and is inclusive (i.e. 12:00:01 includes the first second of the minute)."
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
      style = "form"
      in = "query"
      description = "Returns results with a Post ID less than (that is, older than) the specified ID."
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of search results to be returned by a request."
      style = "form"
      schema = integer(format("int32"), default(10), minimum(10), maximum(500))
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
      in = "query"
      description = "This order in which to return results."
      schema = string(enum("recency", "relevancy"))
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsSearchAllResponse
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
  paths "/2/tweets/{id}/liking_users" "get" {
    operationId = "tweetsIdLikingUsers"
    summary = "Returns User objects that have liked the provided Post ID"
    description = "Returns a list of Users that have liked the provided Post ID"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["like.read", "tweet.read", "users.read"]
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
        schema = components.schemas.Get2TweetsIdLikingUsersResponse
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
    summary = "Pin a List"
    description = "Causes a User to pin a List."
    operationId = "listUserPin"
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the authenticated source User that will pin the List."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    requestBody {
      required = true
      content "application/json" {
        schema = components.schemas.ListPinnedRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListPinnedResponse
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
  paths "/2/users/{id}/pinned_lists" "get" {
    description = "Get a User's Pinned Lists."
    operationId = "listUserPinnedLists"
    summary = "Get a User's Pinned Lists"
    tags = ["Lists"]
    parameters = [components.parameters.ListFieldsParameter, components.parameters.ListExpansionsParameter, components.parameters.UserFieldsParameter]
    security = [{
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the authenticated source User for whom to return results."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
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
        schema = components.schemas.Get2UsersIdPinnedListsResponse
      }
    }
  }
  paths "/2/likes/firehose/stream" "get" {
    parameters = [components.parameters.LikeFieldsParameter, components.parameters.LikeExpansionsParameter, components.parameters.TweetFieldsParameter, components.parameters.UserFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Likes Firehose stream"
    description = "Streams 100% of public Likes."
    operationId = "likesFirehoseStream"
    tags = ["Likes"]
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
    }
    parameters "partition" {
      schema = integer(format("int32"), minimum(1), maximum(20))
      required = true
      in = "query"
      description = "The partition number."
      style = "form"
    }
    parameters "start_time" {
      in = "query"
      example = "2021-02-14T18:40:40.000Z"
      schema = string(format("date-time"))
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Likes will be provided."
      style = "form"
    }
    parameters "end_time" {
      style = "form"
      example = "2021-02-14T18:40:40.000Z"
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
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
  paths "/2/lists/{id}/tweets" "get" {
    summary = "List Posts timeline by List ID."
    description = "Returns a list of Posts associated with the provided List ID."
    operationId = "listsIdTweets"
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
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
      in = "query"
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
  paths "/2/tweets/firehose/stream/lang/en" "get" {
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "English Language Firehose stream"
    description = "Streams 100% of English Language public Posts."
    operationId = "getTweetsFirehoseStreamLangEn"
    tags = ["Tweets"]
    parameters "backfill_minutes" {
      style = "form"
      in = "query"
      description = "The number of minutes of backfill requested."
      schema = integer(format("int32"), maximum(5))
    }
    parameters "partition" {
      required = true
      style = "form"
      in = "query"
      description = "The partition number."
      schema = integer(format("int32"), minimum(1), maximum(8))
    }
    parameters "start_time" {
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = "2021-02-14T18:40:40.000Z"
    }
    parameters "end_time" {
      style = "form"
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      example = "2021-02-14T18:40:40.000Z"
      schema = string(format("date-time"))
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
  paths "/2/tweets/{tweet_id}/hidden" "put" {
    description = "Hides or unhides a reply to an owned conversation."
    operationId = "hideReplyById"
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["tweet.moderate.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Hide replies"
    parameters "tweet_id" {
      in = "path"
      description = "The ID of the reply that you want to hide or unhide."
      style = "simple"
      schema = components.schemas.TweetId
      required = true
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.TweetHideRequest
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
        schema = components.schemas.TweetHideResponse
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
      example = "2244994945"
      schema = components.schemas.UserId
      required = true
      description = "The ID of the User to lookup."
      style = "simple"
      in = "path"
    }
    parameters "max_results" {
      style = "form"
      in = "query"
      description = "The maximum number of results."
      schema = integer(format("int32"), minimum(5), maximum(100))
    }
    parameters "pagination_token" {
      style = "form"
      schema = components.schemas.PaginationToken36
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
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
        schema = components.schemas.Get2UsersIdLikedTweetsResponse
      }
    }
  }
  paths "/2/tweets/counts/all" "get" {
    summary = "Full archive search counts"
    description = "Returns Post Counts that match a search query."
    operationId = "tweetCountsFullArchiveSearch"
    tags = ["Tweets"]
    parameters = [components.parameters.SearchCountFieldsParameter]
    security = [{
      BearerToken = []
    }]
    parameters "query" {
      schema = string(example("(from:TwitterDev OR from:TwitterAPI) has:media -is:retweet"), maxLength(4096), minLength(1))
      required = true
      in = "query"
      description = "One query/rule/filter for matching Posts. Refer to https://t.co/rulelength to identify the max query length."
      style = "form"
    }
    parameters "start_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The oldest UTC timestamp (from most recent 7 days) from which the Posts will be provided. Timestamp is in second granularity and is inclusive (i.e. 12:00:01 includes the first second of the minute)."
      schema = string(format("date-time"))
      style = "form"
      in = "query"
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The newest, most recent UTC timestamp to which the Posts will be provided. Timestamp is in second granularity and is exclusive (i.e. 12:00:01 excludes the first second of the minute)."
      style = "form"
      schema = string(format("date-time"))
    }
    parameters "since_id" {
      description = "Returns results with a Post ID greater than (that is, more recent than) the specified ID."
      schema = components.schemas.TweetId
      style = "form"
      in = "query"
    }
    parameters "until_id" {
      style = "form"
      schema = components.schemas.TweetId
      in = "query"
      description = "Returns results with a Post ID less than (that is, older than) the specified ID."
    }
    parameters "next_token" {
      schema = components.schemas.PaginationToken36
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
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
        schema = components.schemas.Get2TweetsCountsAllResponse
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
      required = true
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
      example = "2244994945"
      schema = components.schemas.UserId
    }
    parameters "max_results" {
      style = "form"
      in = "query"
      description = "The maximum number of results."
      schema = integer(format("int32"), minimum(1), maximum(1000))
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
    summary = "Follow User"
    description = "Causes the User(in the path) to follow, or “request to follow” for protected Users, the target User. The User(in the path) must match the User context authorizing the request"
    operationId = "usersIdFollow"
    tags = ["Users"]
    security = [{
      OAuth2UserToken = ["follows.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      required = true
      description = "The ID of the authenticated source User that is requesting to follow the target User."
      style = "simple"
      in = "path"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.UsersFollowingCreateRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UsersFollowingCreateResponse
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
  paths "/2/users/{id}/mentions" "get" {
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
    summary = "User mention timeline by User ID"
    description = "Returns Post objects that mention username associated to the provided User ID"
    parameters "id" {
      example = "2244994945"
      schema = components.schemas.UserId
      required = true
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
    }
    parameters "since_id" {
      in = "query"
      description = "The minimum Post ID to be included in the result set. This parameter takes precedence over start_time if both are specified."
      style = "form"
      schema = components.schemas.TweetId
    }
    parameters "until_id" {
      in = "query"
      description = "The maximum Post ID to be included in the result set. This parameter takes precedence over end_time if both are specified."
      style = "form"
      example = "1346889436626259968"
      schema = components.schemas.TweetId
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), minimum(5), maximum(100))
    }
    parameters "pagination_token" {
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken36
      in = "query"
    }
    parameters "start_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Posts will be provided. The since_id parameter takes precedence if it is also specified."
      style = "form"
      example = "2021-02-01T18:40:40.000Z"
      schema = string(format("date-time"))
      in = "query"
    }
    parameters "end_time" {
      example = "2021-02-14T18:40:40.000Z"
      schema = string(format("date-time"))
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided. The until_id parameter takes precedence if it is also specified."
      style = "form"
      in = "query"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdMentionsResponse
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
  paths "/2/users/{id}/owned_lists" "get" {
    summary = "Get a User's Owned Lists."
    description = "Get a User's Owned Lists."
    tags = ["Lists"]
    parameters = [components.parameters.ListFieldsParameter, components.parameters.ListExpansionsParameter, components.parameters.UserFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    operationId = "listUserOwnedLists"
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
      example = "2244994945"
      schema = components.schemas.UserId
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
  paths "/2/users/{source_user_id}/muting/{target_user_id}" "delete" {
    summary = "Unmute User by User ID"
    description = "Causes the source User to unmute the target User. The source User must match the User context authorizing the request"
    operationId = "usersIdUnmute"
    tags = ["Users"]
    security = [{
      OAuth2UserToken = ["mute.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "source_user_id" {
      required = true
      in = "path"
      description = "The ID of the authenticated source User that is requesting to unmute the target User."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    parameters "target_user_id" {
      required = true
      in = "path"
      description = "The ID of the User that the source User is requesting to unmute."
      style = "simple"
      schema = components.schemas.UserId
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
        schema = components.schemas.MuteUserMutationResponse
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
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = "2021-02-14T18:40:40.000Z"
      schema = string(format("date-time"))
      in = "query"
    }
    parameters "end_time" {
      schema = string(format("date-time"))
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      style = "form"
      in = "query"
      example = "2021-02-14T18:40:40.000Z"
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
  paths "/2/users/by/username/{username}" "get" {
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "This endpoint returns information about a User. Specify User by username."
    operationId = "findUserByUsername"
    summary = "User lookup by username"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    parameters "username" {
      schema = string(pattern("^[A-Za-z0-9_]{1,15}$"))
      required = true
      in = "path"
      description = "A username."
      style = "simple"
      example = "TwitterDev"
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
      required = true
      style = "form"
      in = "query"
      description = "TThe the query string by which to query for users."
      example = "someXUser"
      schema = components.schemas.UserSearchQuery
    }
    parameters "max_results" {
      in = "query"
      schema = integer(format("int32"), default(100), minimum(1), maximum(1000))
      description = "The maximum number of results."
      style = "form"
    }
    parameters "next_token" {
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      in = "query"
      schema = components.schemas.PaginationToken36
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersSearchResponse
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
    description = "Returns a list of Users who are followers of the specified User ID."
    operationId = "usersIdFollowers"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["follows.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Followers by User ID"
    parameters "id" {
      schema = components.schemas.UserId
      required = true
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
      example = "2244994945"
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(1000))
    }
    parameters "pagination_token" {
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken32
      in = "query"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersIdFollowersResponse
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
  paths "/2/users/{id}/muting" "post" {
    operationId = "usersIdMute"
    tags = ["Users"]
    security = [{
      OAuth2UserToken = ["mute.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Mute User by User ID."
    description = "Causes the User (in the path) to mute the target User. The User (in the path) must match the User context authorizing the request."
    parameters "id" {
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User that is requesting to mute the target User."
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
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      style = "simple"
      in = "path"
      description = "The ID of the authenticated source User for whom to return results."
    }
    parameters "max_results" {
      in = "query"
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(1000))
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
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/users/{id}/retweets/{source_tweet_id}" "delete" {
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["tweet.read", "tweet.write", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Causes the User (in the path) to unretweet the specified Post"
    description = "Causes the User (in the path) to unretweet the specified Post. The User must match the User context authorizing the request"
    operationId = "usersIdUnretweets"
    parameters "id" {
      required = true
      description = "The ID of the authenticated source User that is requesting to repost the Post."
      style = "simple"
      in = "path"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    parameters "source_tweet_id" {
      required = true
      in = "path"
      description = "The ID of the Post that the User is requesting to unretweet."
      style = "simple"
      schema = components.schemas.TweetId
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UsersRetweetsDeleteResponse
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
  paths "/2/users/{source_user_id}/following/{target_user_id}" "delete" {
    summary = "Unfollow User"
    description = "Causes the source User to unfollow the target User. The source User must match the User context authorizing the request"
    operationId = "usersIdUnfollow"
    tags = ["Users"]
    security = [{
      OAuth2UserToken = ["follows.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "source_user_id" {
      required = true
      description = "The ID of the authenticated source User that is requesting to unfollow the target User."
      style = "simple"
      in = "path"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    parameters "target_user_id" {
      required = true
      in = "path"
      description = "The ID of the User that the source User is requesting to unfollow."
      style = "simple"
      schema = components.schemas.UserId
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
  paths "/2/spaces" "get" {
    tags = ["Spaces"]
    parameters = [components.parameters.SpaceFieldsParameter, components.parameters.SpaceExpansionsParameter, components.parameters.UserFieldsParameter, components.parameters.TopicFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    summary = "Space lookup up Space IDs"
    description = "Returns a variety of information about the Spaces specified by the requested IDs"
    operationId = "findSpacesByIds"
    parameters "ids" {
      in = "query"
      description = "The list of Space IDs to return."
      schema = array(maxItems(100), minItems(1), [string(description("The unique identifier of this Space."), example("1SLjjRYNejbKM"), pattern("^[a-zA-Z0-9]{1,13}$"))])
      required = true
      style = "form"
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
      in = "path"
      description = "The ID of the authenticated source User for whom to return results."
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      style = "simple"
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
    description = "Adds a Post (ID in the body) to the requesting User's (in the path) bookmarks"
    operationId = "postUsersIdBookmarks"
    tags = ["Bookmarks"]
    security = [{
      OAuth2UserToken = ["bookmark.write", "tweet.read", "users.read"]
    }]
    parameters "id" {
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User for whom to add bookmarks."
      style = "simple"
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
  paths "/2/lists/{id}" "get" {
    summary = "List lookup by List ID."
    description = "Returns a List."
    operationId = "listIdGet"
    tags = ["Lists"]
    parameters = [components.parameters.ListFieldsParameter, components.parameters.ListExpansionsParameter, components.parameters.UserFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      schema = components.schemas.ListId
      required = true
      description = "The ID of the List."
      style = "simple"
      in = "path"
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
        schema = components.schemas.Get2ListsIdResponse
      }
    }
  }
  paths "/2/lists/{id}" "put" {
    summary = "Update List."
    description = "Update a List that you own."
    operationId = "listIdUpdate"
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
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
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/lists/{id}" "delete" {
    description = "Delete a List that you own."
    operationId = "listIdDelete"
    summary = "Delete List"
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      schema = components.schemas.ListId
      required = true
      style = "simple"
      in = "path"
      description = "The ID of the List to delete."
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.ListDeleteResponse
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
      description = "One query/rule/filter for matching Posts. Refer to https://t.co/rulelength to identify the max query length."
      style = "form"
      in = "query"
      schema = string(example("(from:TwitterDev OR from:TwitterAPI) has:media -is:retweet"), maxLength(4096), minLength(1))
      required = true
    }
    parameters "start_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The oldest UTC timestamp from which the Posts will be provided. Timestamp is in second granularity and is inclusive (i.e. 12:00:01 includes the first second of the minute)."
      style = "form"
      schema = string(format("date-time"))
      in = "query"
    }
    parameters "end_time" {
      style = "form"
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The newest, most recent UTC timestamp to which the Posts will be provided. Timestamp is in second granularity and is exclusive (i.e. 12:00:01 excludes the first second of the minute)."
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
    parameters "max_results" {
      in = "query"
      description = "The maximum number of search results to be returned by a request."
      style = "form"
      schema = integer(format("int32"), default(10), minimum(10), maximum(100))
    }
    parameters "next_token" {
      schema = components.schemas.PaginationToken36
      in = "query"
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
    }
    parameters "pagination_token" {
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      schema = components.schemas.PaginationToken36
      in = "query"
    }
    parameters "sort_order" {
      schema = string(enum("recency", "relevancy"))
      in = "query"
      description = "This order in which to return results."
      style = "form"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsSearchRecentResponse
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
    parameters = [components.parameters.ComplianceJobFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Get Compliance Job"
    description = "Returns a single Compliance Job by ID"
    operationId = "getBatchComplianceJob"
    tags = ["Compliance"]
    parameters "id" {
      style = "simple"
      schema = components.schemas.JobId
      required = true
      in = "path"
      description = "The ID of the Compliance Job to retrieve."
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
  paths "/2/lists/{id}/members/{user_id}" "delete" {
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Remove a List member"
    description = "Causes a User to be removed from the members of a List."
    operationId = "listRemoveMember"
    parameters "id" {
      required = true
      style = "simple"
      in = "path"
      description = "The ID of the List to remove a member."
      schema = components.schemas.ListId
    }
    parameters "user_id" {
      required = true
      in = "path"
      description = "The ID of User that will be removed from the List."
      style = "simple"
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
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/spaces/{id}" "get" {
    operationId = "findSpaceById"
    tags = ["Spaces"]
    parameters = [components.parameters.SpaceFieldsParameter, components.parameters.SpaceExpansionsParameter, components.parameters.UserFieldsParameter, components.parameters.TopicFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    summary = "Space lookup by Space ID"
    description = "Returns a variety of information about the Space specified by the requested ID"
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
  paths "/2/users/{id}/bookmarks/{tweet_id}" "delete" {
    summary = "Remove a bookmarked Post"
    description = "Removes a Post from the requesting User's bookmarked Posts."
    operationId = "usersIdBookmarksDelete"
    tags = ["Bookmarks"]
    security = [{
      OAuth2UserToken = ["bookmark.write", "tweet.read", "users.read"]
    }]
    parameters "id" {
      required = true
      style = "simple"
      in = "path"
      description = "The ID of the authenticated source User whose bookmark is to be removed."
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    parameters "tweet_id" {
      style = "simple"
      schema = components.schemas.TweetId
      required = true
      in = "path"
      description = "The ID of the Post that the source User is removing from bookmarks."
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
    tags = ["Tweets"]
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
    parameters "id" {
      example = "2244994945"
      schema = components.schemas.UserId
      required = true
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
    }
    parameters "since_id" {
      example = "791775337160081409"
      schema = components.schemas.TweetId
      in = "query"
      description = "The minimum Post ID to be included in the result set. This parameter takes precedence over start_time if both are specified."
      style = "form"
    }
    parameters "until_id" {
      style = "form"
      in = "query"
      description = "The maximum Post ID to be included in the result set. This parameter takes precedence over end_time if both are specified."
      example = "1346889436626259968"
      schema = components.schemas.TweetId
    }
    parameters "max_results" {
      style = "form"
      schema = integer(format("int32"), minimum(5), maximum(100))
      in = "query"
      description = "The maximum number of results."
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
      schema = components.schemas.PaginationToken36
      style = "form"
    }
    parameters "exclude" {
      style = "form"
      schema = array(example(["replies", "retweets"]), minItems(1), uniqueItems(true), [string(enum("replies", "retweets"))])
      in = "query"
      description = "The set of entities to exclude (e.g. 'replies' or 'retweets')."
    }
    parameters "start_time" {
      schema = string(format("date-time"))
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Posts will be provided. The since_id parameter takes precedence if it is also specified."
      style = "form"
      in = "query"
      example = "2021-02-01T18:40:40.000Z"
    }
    parameters "end_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided. The until_id parameter takes precedence if it is also specified."
      style = "form"
      in = "query"
      example = "2021-02-14T18:40:40.000Z"
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
      in = "path"
      description = "The ID of the authenticated source User that will unfollow the List."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
    }
    parameters "list_id" {
      in = "path"
      description = "The ID of the List to unfollow."
      style = "simple"
      schema = components.schemas.ListId
      required = true
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
  paths "/2/dm_conversations" "post" {
    operationId = "dmConversationIdCreate"
    summary = "Create a new DM Conversation"
    tags = ["Direct Messages"]
    security = [{
      OAuth2UserToken = ["dm.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Creates a new DM Conversation."
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
  paths "/2/dm_events" "get" {
    summary = "Get recent DM Events"
    description = "Returns recent DM Events across DM conversations"
    operationId = "getDmEvents"
    tags = ["Direct Messages"]
    parameters = [components.parameters.DmEventFieldsParameter, components.parameters.DmEventExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["dm.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "max_results" {
      in = "query"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
      description = "The maximum number of results."
      style = "form"
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken32
    }
    parameters "event_types" {
      style = "form"
      in = "query"
      description = "The set of event_types to include in the results."
      schema = array(example(["MessageCreate", "ParticipantsLeave"]), minItems(1), uniqueItems(true), [string(enum("MessageCreate", "ParticipantsJoin", "ParticipantsLeave"))])
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
      style = "form"
      example = "2021-02-01T18:40:40.000Z"
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Likes Compliance events will be provided."
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp from which the Likes Compliance events will be provided."
      style = "form"
      example = "2021-02-01T18:40:40.000Z"
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
  paths "/2/tweets/firehose/stream/lang/ko" "get" {
    summary = "Korean Language Firehose stream"
    description = "Streams 100% of Korean Language public Posts."
    operationId = "getTweetsFirehoseStreamLangKo"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
    }
    parameters "partition" {
      description = "The partition number."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(2))
      required = true
      in = "query"
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = "2021-02-14T18:40:40.000Z"
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      example = "2021-02-14T18:40:40.000Z"
      schema = string(format("date-time"))
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
        schema = components.schemas.StreamingTweetResponse
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/tweets/label/stream" "get" {
    tags = ["Compliance"]
    security = [{
      BearerToken = []
    }]
    summary = "Posts Label stream"
    description = "Streams 100% of labeling events applied to Posts"
    operationId = "getTweetsLabelStream"
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
    }
    parameters "start_time" {
      schema = string(format("date-time"))
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Post labels will be provided."
      style = "form"
      in = "query"
      example = "2021-02-01T18:40:40.000Z"
    }
    parameters "end_time" {
      in = "query"
      example = "2021-02-01T18:40:40.000Z"
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
    security = [{
      BearerToken = []
    }]
    summary = "Sample 10% stream"
    description = "Streams a deterministic 10% of public Posts."
    operationId = "getTweetsSample10Stream"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
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
      schema = integer(format("int32"), minimum(1), maximum(2))
    }
    parameters "start_time" {
      style = "form"
      example = "2021-02-14T18:40:40.000Z"
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
    }
    parameters "end_time" {
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = "2021-02-14T18:40:40.000Z"
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
  paths "/2/users/{id}" "get" {
    summary = "User lookup by ID"
    description = "This endpoint returns information about a User. Specify User by ID."
    operationId = "findUserById"
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
      example = "2244994945"
      schema = components.schemas.UserId
      required = true
      in = "path"
      description = "The ID of the User to lookup."
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
        schema = components.schemas.Get2UsersIdResponse
      }
    }
  }
  paths "/2/dm_conversations/with/{participant_id}/messages" "post" {
    security = [{
      OAuth2UserToken = ["dm.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Creates a new message for a DM Conversation with a participant user by ID"
    operationId = "dmConversationWithUserEventIdCreate"
    summary = "Send a new message to a user"
    tags = ["Direct Messages"]
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
  paths "/2/dm_conversations/{id}/dm_events" "get" {
    parameters = [components.parameters.DmEventFieldsParameter, components.parameters.DmEventExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["dm.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Get DM Events for a DM Conversation"
    description = "Returns DM Events for a DM Conversation"
    operationId = "getDmConversationsIdDmEvents"
    tags = ["Direct Messages"]
    parameters "id" {
      description = "The DM Conversation ID."
      style = "simple"
      schema = components.schemas.DmConversationId
      required = true
      in = "path"
    }
    parameters "max_results" {
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
      in = "query"
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
      schema = array(example(["MessageCreate", "ParticipantsLeave"]), minItems(1), uniqueItems(true), [string(enum("MessageCreate", "ParticipantsJoin", "ParticipantsLeave"))])
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2DmConversationsIdDmEventsResponse
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
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Returns a list of Users that follow a List by the provided List ID"
    operationId = "listGetFollowers"
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the List."
      style = "simple"
      schema = components.schemas.ListId
    }
    parameters "max_results" {
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
      description = "The maximum number of results."
      style = "form"
      in = "query"
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationTokenLong
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
        schema = components.schemas.Get2ListsIdFollowersResponse
      }
    }
  }
  paths "/2/tweets/sample/stream" "get" {
    security = [{
      BearerToken = []
    }]
    summary = "Sample stream"
    description = "Streams a deterministic 1% of public Posts."
    operationId = "sampleStream"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      schema = integer(format("int32"), maximum(5))
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
  paths "/2/usage/tweets" "get" {
    security = [{
      BearerToken = []
    }]
    summary = "Post Usage"
    description = "Returns the Post Usage."
    operationId = "getUsageTweets"
    tags = ["Usage"]
    parameters = [components.parameters.UsageFieldsParameter]
    parameters "days" {
      schema = integer(format("int32"), default(7), minimum(1), maximum(90))
      style = "form"
      in = "query"
      description = "The number of days for which you need usage for."
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
  paths "/2/users/{id}/pinned_lists/{list_id}" "delete" {
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Unpin a List"
    description = "Causes a User to remove a pinned List."
    operationId = "listUserUnpin"
    tags = ["Lists"]
    parameters "id" {
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      style = "simple"
      in = "path"
      description = "The ID of the authenticated source User for whom to return results."
    }
    parameters "list_id" {
      required = true
      style = "simple"
      in = "path"
      description = "The ID of the List to unpin."
      schema = components.schemas.ListId
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
        schema = components.schemas.ListUnpinResponse
      }
    }
  }
  paths "/2/tweets/compliance/stream" "get" {
    tags = ["Compliance"]
    security = [{
      BearerToken = []
    }]
    summary = "Posts Compliance stream"
    description = "Streams 100% of compliance data for Posts"
    operationId = "getTweetsComplianceStream"
    parameters "backfill_minutes" {
      schema = integer(format("int32"), maximum(5))
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
    }
    parameters "partition" {
      required = true
      in = "query"
      description = "The partition number."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(4))
    }
    parameters "start_time" {
      style = "form"
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Post Compliance events will be provided."
      example = "2021-02-01T18:40:40.000Z"
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Post Compliance events will be provided."
      style = "form"
      example = "2021-02-14T18:40:40.000Z"
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
        schema = components.schemas.TweetComplianceStreamResponse
      }
    }
    specificationExtension {
      x-twitter-streaming = "true"
    }
  }
  paths "/2/tweets/firehose/stream" "get" {
    summary = "Firehose stream"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }]
    description = "Streams 100% of public Posts."
    operationId = "getTweetsFirehoseStream"
    parameters "backfill_minutes" {
      style = "form"
      in = "query"
      schema = integer(format("int32"), maximum(5))
      description = "The number of minutes of backfill requested."
    }
    parameters "partition" {
      required = true
      style = "form"
      in = "query"
      description = "The partition number."
      schema = integer(format("int32"), minimum(1), maximum(20))
    }
    parameters "start_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = "2021-02-14T18:40:40.000Z"
      schema = string(format("date-time"))
    }
    parameters "end_time" {
      example = "2021-02-14T18:40:40.000Z"
      schema = string(format("date-time"))
      style = "form"
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
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
  paths "/2/users/{id}/followed_lists" "get" {
    operationId = "userFollowedLists"
    tags = ["Lists"]
    parameters = [components.parameters.ListFieldsParameter, components.parameters.ListExpansionsParameter, components.parameters.UserFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["list.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Get User's Followed Lists"
    description = "Returns a User's followed Lists."
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
      example = "2244994945"
      schema = components.schemas.UserId
    }
    parameters "max_results" {
      description = "The maximum number of results."
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
      style = "form"
      in = "query"
    }
    parameters "pagination_token" {
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationTokenLong
      in = "query"
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
    summary = "Follow a List"
    description = "Causes a User to follow a List."
    operationId = "listUserFollow"
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      description = "The ID of the authenticated source User that will follow the List."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
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
  paths "/2/compliance/jobs" "get" {
    parameters = [components.parameters.ComplianceJobFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "List Compliance Jobs"
    description = "Returns recent Compliance Jobs for a given job type and optional job status"
    operationId = "listBatchComplianceJobs"
    tags = ["Compliance"]
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
      schema = string(enum("created", "in_progress", "failed", "complete"))
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
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.CreateComplianceJobResponse
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
  paths "/2/lists" "post" {
    description = "Creates a new List."
    operationId = "listIdCreate"
    tags = ["Lists"]
    security = [{
      OAuth2UserToken = ["list.read", "list.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Create List"
    requestBody {
      content "application/json" {
        schema = components.schemas.ListCreateRequest
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
        schema = components.schemas.ListCreateResponse
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
  paths "/2/spaces/by/creator_ids" "get" {
    summary = "Space lookup by their creators"
    description = "Returns a variety of information about the Spaces created by the provided User IDs"
    operationId = "findSpacesByCreatorIds"
    tags = ["Spaces"]
    parameters = [components.parameters.SpaceFieldsParameter, components.parameters.SpaceExpansionsParameter, components.parameters.UserFieldsParameter, components.parameters.TopicFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    parameters "user_ids" {
      schema = array(maxItems(100), minItems(1), [components.schemas.UserId])
      required = true
      style = "form"
      in = "query"
      description = "The IDs of Users to search through."
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
        schema = components.schemas.Get2SpacesByCreatorIdsResponse
      }
    }
  }
  paths "/2/tweets" "get" {
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Returns a variety of information about the Post specified by the requested ID."
    operationId = "findTweetsById"
    summary = "Post lookup by Post IDs"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    parameters "ids" {
      required = true
      description = "A comma separated list of Post IDs. Up to 100 are allowed in a single request."
      style = "form"
      in = "query"
      schema = array(maxItems(100), minItems(1), [components.schemas.TweetId])
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsResponse
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
  paths "/2/tweets" "post" {
    security = [{
      OAuth2UserToken = ["tweet.read", "tweet.write", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Creation of a Post"
    description = "Causes the User to create a Post under the authorized account."
    operationId = "createTweet"
    tags = ["Tweets"]
    requestBody {
      required = true
      content "application/json" {
        schema = components.schemas.TweetCreateRequest
      }
    }
    responses "201" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.TweetCreateResponse
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
    summary = "Post lookup by Post ID"
    description = "Returns a variety of information about the Post specified by the requested ID."
    operationId = "findTweetById"
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
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsIdResponse
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
  paths "/2/tweets/{id}" "delete" {
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["tweet.read", "tweet.write", "users.read"]
    }, {
      UserToken = []
    }]
    description = "Delete specified Post (in the path) by ID."
    operationId = "deleteTweetById"
    summary = "Post delete by Post ID"
    parameters "id" {
      schema = components.schemas.TweetId
      required = true
      in = "path"
      description = "The ID of the Post to be deleted."
      style = "simple"
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
        schema = components.schemas.TweetDeleteResponse
      }
    }
  }
  paths "/2/tweets/{id}/retweeted_by" "get" {
    description = "Returns a list of Users that have retweeted the provided Post ID"
    operationId = "tweetsIdRetweetingUsers"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Returns User objects that have retweeted the provided Post ID"
    parameters "id" {
      description = "A single Post ID."
      style = "simple"
      schema = components.schemas.TweetId
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
      description = "This parameter is used to get the next 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken36
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TweetsIdRetweetedByResponse
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
  paths "/2/likes/sample10/stream" "get" {
    tags = ["Likes"]
    parameters = [components.parameters.LikeFieldsParameter, components.parameters.LikeExpansionsParameter, components.parameters.TweetFieldsParameter, components.parameters.UserFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Likes Sample 10 stream"
    description = "Streams 10% of public Likes."
    operationId = "likesSample10Stream"
    parameters "backfill_minutes" {
      in = "query"
      description = "The number of minutes of backfill requested."
      style = "form"
      schema = integer(format("int32"), maximum(5))
    }
    parameters "partition" {
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(2))
      required = true
      in = "query"
      description = "The partition number."
    }
    parameters "start_time" {
      schema = string(format("date-time"))
      style = "form"
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp to which the Likes will be provided."
      example = "2021-02-14T18:40:40.000Z"
    }
    parameters "end_time" {
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided."
      style = "form"
      example = "2021-02-14T18:40:40.000Z"
      schema = string(format("date-time"))
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
  paths "/2/spaces/{id}/buyers" "get" {
    operationId = "spaceBuyers"
    summary = "Retrieve the list of Users who purchased a ticket to the given space"
    tags = ["Spaces", "Tweets"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    description = "Retrieves the list of Users who purchased a ticket to the given space"
    parameters "id" {
      description = "The ID of the Space to be retrieved."
      style = "simple"
      example = "1YqKDqWqdPLsV"
      schema = string(description("The unique identifier of this Space."), example("1SLjjRYNejbKM"), pattern("^[a-zA-Z0-9]{1,13}$"))
      required = true
      in = "path"
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken32
    }
    parameters "max_results" {
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
      style = "form"
      in = "query"
      description = "The maximum number of results."
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2SpacesIdBuyersResponse
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
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "User lookup me"
    description = "This endpoint returns information about the requesting User."
    operationId = "findMyUser"
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2UsersMeResponse
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
  paths "/2/spaces/{id}/tweets" "get" {
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["space.read", "tweet.read", "users.read"]
    }]
    summary = "Retrieve Posts from a Space."
    description = "Retrieves Posts shared in the specified Space."
    operationId = "spaceTweets"
    tags = ["Spaces", "Tweets"]
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
  paths "/2/trends/by/woeid/{woeid}" "get" {
    description = "Returns the Trend associated with the supplied WoeId."
    operationId = "getTrends"
    tags = ["Trends"]
    parameters = [components.parameters.TrendFieldsParameter]
    security = [{
      BearerToken = []
    }]
    summary = "Trends"
    parameters "woeid" {
      in = "path"
      example = "2244994945"
      schema = integer(format("int32"))
      required = true
      description = "The WOEID of the place to lookup a trend for."
      style = "simple"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2TrendsByWoeidWoeidResponse
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
  paths "/2/tweets/search/stream/rules" "get" {
    summary = "Rules lookup"
    description = "Returns rules from a User's active rule set. Users can fetch all of their rules or a subset, specified by the provided rule ids."
    operationId = "getRules"
    tags = ["Tweets"]
    security = [{
      BearerToken = []
    }]
    parameters "ids" {
      style = "form"
      in = "query"
      description = "A comma-separated list of Rule IDs."
      schema = array([components.schemas.RuleId])
    }
    parameters "max_results" {
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(1000), minimum(1), maximum(1000))
      in = "query"
    }
    parameters "pagination_token" {
      in = "query"
      description = "This value is populated by passing the 'next_token' returned in a request to paginate through results."
      schema = string(maxLength(16), minLength(16))
      style = "form"
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
        schema = components.schemas.RulesLookupResponse
      }
    }
  }
  paths "/2/tweets/search/stream/rules" "post" {
    security = [{
      BearerToken = []
    }]
    summary = "Add/Delete rules"
    description = "Add or delete rules from a User's active rule set. Users can provide unique, optionally tagged rules to add. Users can delete their entire rule set or a subset specified by rule ids or values."
    operationId = "addOrDeleteRules"
    tags = ["Tweets"]
    parameters "dry_run" {
      in = "query"
      description = "Dry Run can be used with both the add and delete action, with the expected result given, but without actually taking any action in the system (meaning the end state will always be as it was when the request was submitted). This is particularly useful to validate rule changes."
      style = "form"
      schema = boolean()
    }
    parameters "delete_all" {
      in = "query"
      description = "Delete All can be used to delete all of the rules associated this client app, it should be specified with no other parameters. Once deleted, rules cannot be recovered."
      style = "form"
      schema = boolean()
    }
    requestBody {
      required = true
      content "application/json" {
        schema = components.schemas.AddOrDeleteRulesRequest
      }
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.AddOrDeleteRulesResponse
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
  paths "/2/tweets/{id}/retweets" "get" {
    description = "Returns a variety of information about each Post that has retweeted the Post specified by the requested ID."
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    operationId = "findTweetsThatRetweetATweet"
    summary = "Retrieve Posts that repost a Post."
    parameters "id" {
      style = "simple"
      schema = components.schemas.TweetId
      required = true
      in = "path"
      description = "A single Post ID."
    }
    parameters "max_results" {
      description = "The maximum number of results."
      style = "form"
      in = "query"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
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
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
      content "application/json" {
        schema = components.schemas.Error
      }
    }
  }
  paths "/2/users/{id}/likes/{tweet_id}" "delete" {
    summary = "Causes the User (in the path) to unlike the specified Post"
    description = "Causes the User (in the path) to unlike the specified Post. The User must match the User context authorizing the request"
    operationId = "usersIdUnlike"
    tags = ["Tweets"]
    security = [{
      OAuth2UserToken = ["like.write", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "id" {
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User that is requesting to unlike the Post."
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
  paths "/2/users/{id}/list_memberships" "get" {
    description = "Get a User's List Memberships."
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
    parameters "id" {
      required = true
      in = "path"
      description = "The ID of the User to lookup."
      style = "simple"
      example = "2244994945"
      schema = components.schemas.UserId
    }
    parameters "max_results" {
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
      description = "The maximum number of results."
      style = "form"
      in = "query"
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationTokenLong
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
        schema = components.schemas.Get2UsersIdListMembershipsResponse
      }
    }
  }
  paths "/2/users/{id}/timelines/reverse_chronological" "get" {
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    security = [{
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "User home timeline by User ID"
    description = "Returns Post objects that appears in the provided User ID's home timeline"
    operationId = "usersIdTimeline"
    parameters "id" {
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
      required = true
      in = "path"
      description = "The ID of the authenticated source User to list Reverse Chronological Timeline Posts of."
    }
    parameters "since_id" {
      description = "The minimum Post ID to be included in the result set. This parameter takes precedence over start_time if both are specified."
      style = "form"
      example = "791775337160081409"
      schema = components.schemas.TweetId
      in = "query"
    }
    parameters "until_id" {
      in = "query"
      description = "The maximum Post ID to be included in the result set. This parameter takes precedence over end_time if both are specified."
      style = "form"
      example = "1346889436626259968"
      schema = components.schemas.TweetId
    }
    parameters "max_results" {
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(100))
      in = "query"
    }
    parameters "pagination_token" {
      style = "form"
      schema = components.schemas.PaginationToken36
      in = "query"
      description = "This parameter is used to get the next 'page' of results."
    }
    parameters "exclude" {
      style = "form"
      in = "query"
      description = "The set of entities to exclude (e.g. 'replies' or 'retweets')."
      schema = array(example(["replies", "retweets"]), uniqueItems(true), [string(enum("replies", "retweets"))])
    }
    parameters "start_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the Posts will be provided. The since_id parameter takes precedence if it is also specified."
      style = "form"
      example = "2021-02-01T18:40:40.000Z"
      schema = string(format("date-time"))
      in = "query"
    }
    parameters "end_time" {
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp to which the Posts will be provided. The until_id parameter takes precedence if it is also specified."
      example = "2021-02-14T18:40:40.000Z"
      schema = string(format("date-time"))
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
        schema = components.schemas.Get2UsersIdTimelinesReverseChronologicalResponse
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
      schema = components.schemas.UserId
      required = true
      in = "path"
      description = "The ID of the participant user for the One to One DM conversation."
      style = "simple"
    }
    parameters "max_results" {
      description = "The maximum number of results."
      style = "form"
      schema = integer(format("int32"), default(100), minimum(1), maximum(100))
      in = "query"
    }
    parameters "pagination_token" {
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
      style = "form"
      schema = components.schemas.PaginationToken32
    }
    parameters "event_types" {
      style = "form"
      in = "query"
      description = "The set of event_types to include in the results."
      schema = array(example(["MessageCreate", "ParticipantsLeave"]), minItems(1), uniqueItems(true), [string(enum("MessageCreate", "ParticipantsJoin", "ParticipantsLeave"))])
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.Get2DmConversationsWithParticipantIdDmEventsResponse
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
    tags = ["Direct Messages"]
    security = [{
      OAuth2UserToken = ["dm.read", "dm.write"]
    }, {
      UserToken = []
    }]
    description = "Delete a Dm Event that you own."
    operationId = "dmEventDelete"
    summary = "Delete Dm"
    parameters "event_id" {
      description = "The ID of the direct-message event to delete."
      style = "simple"
      schema = components.schemas.DmEventId
      required = true
      in = "path"
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
  paths "/2/dm_events/{event_id}" "get" {
    summary = "Get DM Events by id"
    description = "Returns DM Events by event id."
    operationId = "getDmEventsById"
    tags = ["Direct Messages"]
    parameters = [components.parameters.DmEventFieldsParameter, components.parameters.DmEventExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      OAuth2UserToken = ["dm.read", "tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "event_id" {
      required = true
      style = "simple"
      in = "path"
      description = "dm event id."
      schema = components.schemas.DmEventId
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
  paths "/2/tweets/counts/recent" "get" {
    summary = "Recent search counts"
    description = "Returns Post Counts from the last 7 days that match a search query."
    operationId = "tweetCountsRecentSearch"
    tags = ["Tweets"]
    parameters = [components.parameters.SearchCountFieldsParameter]
    security = [{
      BearerToken = []
    }]
    parameters "query" {
      description = "One query/rule/filter for matching Posts. Refer to https://t.co/rulelength to identify the max query length."
      style = "form"
      schema = string(example("(from:TwitterDev OR from:TwitterAPI) has:media -is:retweet"), maxLength(4096), minLength(1))
      required = true
      in = "query"
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
      schema = components.schemas.PaginationToken36
      description = "This parameter is used to get the next 'page' of results. The value used with the parameter is pulled directly from the response provided by the API, and should not be modified."
      style = "form"
      in = "query"
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
      content "application/json" {
        schema = components.schemas.Error
      }
      content "application/problem+json" {
        schema = components.schemas.Problem
      }
    }
  }
  paths "/2/tweets/{id}/quote_tweets" "get" {
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    summary = "Retrieve Posts that quote a Post."
    description = "Returns a variety of information about each Post that quotes the Post specified by the requested ID."
    operationId = "findTweetsThatQuoteATweet"
    tags = ["Tweets"]
    parameters = [components.parameters.TweetFieldsParameter, components.parameters.TweetExpansionsParameter, components.parameters.MediaFieldsParameter, components.parameters.PollFieldsParameter, components.parameters.UserFieldsParameter, components.parameters.PlaceFieldsParameter]
    parameters "id" {
      style = "simple"
      in = "path"
      description = "A single Post ID."
      schema = components.schemas.TweetId
      required = true
    }
    parameters "max_results" {
      description = "The maximum number of results to be returned."
      schema = integer(format("int32"), default(10), minimum(10), maximum(100))
      style = "form"
      in = "query"
    }
    parameters "pagination_token" {
      style = "form"
      schema = components.schemas.PaginationToken36
      in = "query"
      description = "This parameter is used to get a specified 'page' of results."
    }
    parameters "exclude" {
      description = "The set of entities to exclude (e.g. 'replies' or 'retweets')."
      style = "form"
      schema = array(example(["replies", "retweets"]), minItems(1), uniqueItems(true), [string(enum("replies", "retweets"))])
      in = "query"
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
  paths "/2/users/by" "get" {
    summary = "User lookup by usernames"
    description = "This endpoint returns information about Users. Specify Users by their username."
    operationId = "findUsersByUsername"
    tags = ["Users"]
    parameters = [components.parameters.UserFieldsParameter, components.parameters.UserExpansionsParameter, components.parameters.TweetFieldsParameter]
    security = [{
      BearerToken = []
    }, {
      OAuth2UserToken = ["tweet.read", "users.read"]
    }, {
      UserToken = []
    }]
    parameters "usernames" {
      style = "form"
      in = "query"
      schema = array(example("TwitterDev,TwitterAPI"), maxItems(100), minItems(1), [string(description("The X handle (screen name) of this User."), pattern("^[A-Za-z0-9_]{1,15}$"))])
      required = true
      description = "A list of usernames, comma-separated."
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
  paths "/2/users/compliance/stream" "get" {
    summary = "Users Compliance stream"
    description = "Streams 100% of compliance data for Users"
    operationId = "getUsersComplianceStream"
    tags = ["Compliance"]
    security = [{
      BearerToken = []
    }]
    parameters "backfill_minutes" {
      schema = integer(format("int32"), maximum(5))
      description = "The number of minutes of backfill requested."
      style = "form"
      in = "query"
    }
    parameters "partition" {
      style = "form"
      schema = integer(format("int32"), minimum(1), maximum(4))
      required = true
      in = "query"
      description = "The partition number."
    }
    parameters "start_time" {
      example = "2021-02-01T18:40:40.000Z"
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The earliest UTC timestamp from which the User Compliance events will be provided."
      style = "form"
    }
    parameters "end_time" {
      example = "2021-02-01T18:40:40.000Z"
      schema = string(format("date-time"))
      in = "query"
      description = "YYYY-MM-DDTHH:mm:ssZ. The latest UTC timestamp from which the User Compliance events will be provided."
      style = "form"
    }
    responses "200" {
      description = "The request has succeeded."
      content "application/json" {
        schema = components.schemas.UserComplianceStreamResponse
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
      required = true
      in = "path"
      description = "The ID of the authenticated source User that is requesting to repost the Post."
      style = "simple"
      schema = components.schemas.UserIdMatchesAuthenticatedUser
    }
    requestBody {
      content "application/json" {
        schema = components.schemas.UsersRetweetsCreateRequest
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
        schema = components.schemas.UsersRetweetsCreateResponse
      }
    }
  }
  components "schemas" "Get2ListsIdFollowersResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.User])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "Usage" {
    description = "Usage per client app"
    type = "object"
    properties {
      project_id = string(format("^[0-9]{1,19}$"), description("The unique identifier for this project"))
      project_usage = integer(format("int32"), description("The number of Posts read in this project"))
      cap_reset_day = integer(format("int32"), description("Number of days left for the Tweet cap to reset"))
      daily_client_app_usage = array(description("The daily usage breakdown for each Client Application a project"), minItems(1), [components.schemas.ClientAppUsage])
      daily_project_usage = object(description("The daily usage breakdown for a project"), {
        project_id = integer(format("int32"), description("The unique identifier for this project")),
        usage = array(description("The usage value"), minItems(1), [components.schemas.UsageFields])
      })
      project_cap = integer(format("int32"), description("Total number of Posts that can be read in this project per month"))
    }
  }
  components "schemas" "UsersFollowingCreateRequest" {
    type = "object"
    required = ["target_user_id"]
    properties {
      target_user_id = components.schemas.UserId
    }
  }
  components "schemas" "Get2TweetsFirehoseStreamLangJaResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "MediaHeight" {
    type = "integer"
    description = "The height of the media in pixels."
  }
  components "schemas" "TweetTakedownComplianceSchema" {
    type = "object"
    required = ["tweet", "withheld_in_countries", "event_at"]
    properties {
      tweet = object(required(["id", "author_id"]), {
        author_id = components.schemas.UserId,
        id = components.schemas.TweetId
      })
      withheld_in_countries = array(minItems(1), [components.schemas.CountryCode])
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      quote_tweet_id = components.schemas.TweetId
    }
  }
  components "schemas" "Get2UsersIdResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      data = components.schemas.User
    }
  }
  components "schemas" "OldestId" {
    type = "string"
    description = "The oldest id in this response."
  }
  components "schemas" "ComplianceJobName" {
    maxLength = 64
    type = "string"
    description = "User-provided name for a compliance job."
    example = "my-job"
  }
  components "schemas" "TweetWithheld" {
    type = "object"
    description = "Indicates withholding details for [withheld content](https://help.twitter.com/en/rules-and-policies/tweet-withheld-by-country)."
    required = ["copyright", "country_codes"]
    properties {
      copyright = boolean(description("Indicates if the content is being withheld for on the basis of copyright infringement."))
      country_codes = array(description("Provides a list of countries where this content is not available."), minItems(1), uniqueItems(true), [components.schemas.CountryCode])
      scope = string(description("Indicates whether the content being withheld is the `tweet` or a `user`."), enum("tweet", "user"))
    }
  }
  components "schemas" "Get2TweetsIdQuoteTweetsResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.Tweet])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "MentionEntity" {
    allOf = [components.schemas.EntityIndicesInclusiveExclusive, components.schemas.MentionFields]
  }
  components "schemas" "OperationalDisconnectProblem" {
    description = "You have been disconnected for operational reasons."
    allOf = [components.schemas.Problem, object({
      disconnect_type = string(enum("OperationalDisconnect", "UpstreamOperationalDisconnect", "ForceDisconnect", "UpstreamUncleanDisconnect", "SlowReader", "InternalError", "ClientApplicationStateDegraded", "InvalidRules"))
    })]
  }
  components "schemas" "CountryCode" {
    type = "string"
    description = "A two-letter ISO 3166-1 alpha-2 country code."
    example = "US"
    pattern = "^[A-Z]{2}$"
  }
  components "schemas" "CreateTextMessageRequest" {
    type = "object"
    required = ["text"]
    properties {
      text = string(description("Text of the message."), minLength(1))
      attachments = components.schemas.DmAttachments
    }
  }
  components "schemas" "UrlImage" {
    type = "object"
    description = "Represent the information for the URL image."
    properties {
      url = components.schemas.Url
      width = components.schemas.MediaWidth
      height = components.schemas.MediaHeight
    }
  }
  components "schemas" "CreateMessageRequest" {
    anyOf = [components.schemas.CreateTextMessageRequest, components.schemas.CreateAttachmentsMessageRequest]
  }
  components "schemas" "UnsupportedAuthenticationProblem" {
    description = "A problem that indicates that the authentication used is not supported."
    allOf = [components.schemas.Problem]
  }
  components "schemas" "UserId" {
    description = "Unique identifier of this User. This is returned as a string in order to avoid complications with languages and tools that cannot handle large integers."
    example = "2244994945"
    pattern = "^[0-9]{1,19}$"
    type = "string"
  }
  components "schemas" "Variants" {
    type = "array"
    description = "An array of all available variants of the media."
    items = [components.schemas.Variant]
  }
  components "schemas" "AppRulesCount" {
    type = "object"
    description = "A count of user-provided stream filtering rules at the client application level."
    properties {
      client_app_id = components.schemas.ClientAppId
      rule_count = integer(format("int32"), description("Number of rules for client application"))
    }
  }
  components "schemas" "Get2UsersIdBookmarksResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.Tweet])
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Photo" {
    allOf = [components.schemas.Media, object({
      alt_text = string(),
      url = string(format("uri"))
    })]
  }
  components "schemas" "Get2TweetsResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.Tweet])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "MuteUserMutationResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      data = object({
        muting = boolean()
      })
    }
  }
  components "schemas" "PlaceId" {
    type = "string"
    description = "The identifier for this place."
    example = "f7eb2fa2fea288b1"
  }
  components "schemas" "AddRulesRequest" {
    type = "object"
    description = "A request to add a user-specified stream filtering rule."
    required = ["add"]
    properties {
      add = array([components.schemas.RuleNoId])
    }
  }
  components "schemas" "DmConversationId" {
    example = "123123123-456456456"
    pattern = "^([0-9]{1,19}-[0-9]{1,19}|[0-9]{15,19})$"
    type = "string"
    description = "Unique identifier of a DM conversation. This can either be a numeric string, or a pair of numeric strings separated by a '-' character in the case of one-on-one DM Conversations."
  }
  components "schemas" "Get2ListsIdTweetsResponse" {
    type = "object"
    properties {
      meta = object({
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken
      })
      data = array(minItems(1), [components.schemas.Tweet])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2SpacesIdTweetsResponse" {
    type = "object"
    properties {
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.Tweet])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2UsersByResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      data = array(minItems(1), [components.schemas.User])
    }
  }
  components "schemas" "RuleTag" {
    type = "string"
    description = "A tag meant for the labeling of user provided rules."
    example = "Non-retweeted coffee Posts"
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
  components "schemas" "StreamingTweetResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "TweetLabelStreamResponse" {
    description = "Tweet label stream events."
    oneOf = [object(description("Tweet Label event."), required(["data"]), {
      data = components.schemas.TweetLabelData
    }), object(required(["errors"]), {
      errors = array(minItems(1), [components.schemas.Problem])
    })]
  }
  components "schemas" "UsersLikesCreateRequest" {
    type = "object"
    required = ["tweet_id"]
    properties {
      tweet_id = components.schemas.TweetId
    }
  }
  components "schemas" "ListFollowedRequest" {
    type = "object"
    required = ["list_id"]
    properties {
      list_id = components.schemas.ListId
    }
  }
  components "schemas" "ListFollowedResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      data = object({
        following = boolean()
      })
    }
  }
  components "schemas" "Poll" {
    type = "object"
    description = "Represent a Poll attached to a Tweet."
    required = ["id", "options"]
    properties {
      end_datetime = string(format("date-time"))
      id = components.schemas.PollId
      options = array(maxItems(4), minItems(2), [components.schemas.PollOption])
      voting_status = string(enum("open", "closed"))
      duration_minutes = integer(format("int32"), minimum(5), maximum(10080))
    }
  }
  components "schemas" "RuleId" {
    type = "string"
    description = "Unique identifier of this rule."
    example = "120897978112909812"
    pattern = "^[0-9]{1,19}$"
  }
  components "schemas" "DisallowedResourceProblem" {
    description = "A problem that indicates that the resource requested violates the precepts of this API."
    allOf = [components.schemas.Problem, object(required(["resource_id", "resource_type", "section"]), {
      section = string(enum("data", "includes")),
      resource_id = string(),
      resource_type = string(enum("user", "tweet", "media", "list", "space"))
    })]
  }
  components "schemas" "DownloadUrl" {
    type = "string"
    format = "uri"
    description = "URL from which the user will retrieve their compliance results."
  }
  components "schemas" "ListPinnedResponse" {
    type = "object"
    properties {
      data = object({
        pinned = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Get2UsersSearchResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.User])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        previous_token = components.schemas.PreviousToken,
        next_token = components.schemas.NextToken
      })
    }
  }
  components "schemas" "LikeId" {
    type = "string"
    description = "The unique identifier of this Like."
    example = "8ba4f34e6235d905a46bac021d98e923"
    pattern = "^[A-Za-z0-9_]{1,40}$"
  }
  components "schemas" "LikesComplianceStreamResponse" {
    oneOf = [object(description("Compliance event."), required(["data"]), {
      data = components.schemas.LikeComplianceSchema
    }), object(required(["errors"]), {
      errors = array(minItems(1), [components.schemas.Problem])
    })]
    description = "Likes compliance stream events."
  }
  components "schemas" "RulesLookupResponse" {
    type = "object"
    required = ["meta"]
    properties {
      meta = components.schemas.RulesResponseMetadata
      data = array([components.schemas.Rule])
    }
  }
  components "schemas" "Start" {
    description = "The start time of the bucket."
    type = "string"
    format = "date-time"
  }
  components "schemas" "Expansions" {
    type = "object"
    properties {
      media = array(minItems(1), [components.schemas.Media])
      places = array(minItems(1), [components.schemas.Place])
      polls = array(minItems(1), [components.schemas.Poll])
      topics = array(minItems(1), [components.schemas.Topic])
      tweets = array(minItems(1), [components.schemas.Tweet])
      users = array(minItems(1), [components.schemas.User])
    }
  }
  components "schemas" "Get2DmConversationsIdDmEventsResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.DmEvent])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken
      })
    }
  }
  components "schemas" "Get2LikesFirehoseStreamResponse" {
    type = "object"
    properties {
      data = components.schemas.Like
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "UnlikeComplianceSchema" {
    type = "object"
    required = ["favorite", "event_at"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      favorite = object(required(["id", "user_id"]), {
        id = components.schemas.TweetId,
        user_id = components.schemas.UserId
      })
    }
  }
  components "schemas" "UsersLikesCreateResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      data = object({
        liked = boolean()
      })
    }
  }
  components "schemas" "TweetId" {
    type = "string"
    description = "Unique identifier of this Tweet. This is returned as a string in order to avoid complications with languages and tools that cannot handle large integers."
    example = "1346889436626259968"
    pattern = "^[0-9]{1,19}$"
  }
  components "schemas" "Get2UsersIdTimelinesReverseChronologicalResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.Tweet])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        oldest_id = components.schemas.OldestId,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount,
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken
      })
    }
  }
  components "schemas" "HashtagEntity" {
    allOf = [components.schemas.EntityIndicesInclusiveExclusive, components.schemas.HashtagFields]
  }
  components "schemas" "JobId" {
    type = "string"
    description = "Compliance Job ID."
    example = "1372966999991541762"
    pattern = "^[0-9]{1,19}$"
  }
  components "schemas" "ClientAppId" {
    type = "string"
    description = "The ID of the client application"
    minLength = 1
    maxLength = 19
  }
  components "schemas" "Get2SpacesIdBuyersResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.User])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "Get2TrendsByWoeidWoeidResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.Trend])
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "CreateDmEventResponse" {
    type = "object"
    properties {
      data = object(required(["dm_conversation_id", "dm_event_id"]), {
        dm_conversation_id = components.schemas.DmConversationId,
        dm_event_id = components.schemas.DmEventId
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "DmAttachments" {
    type = "array"
    description = "Attachments to a DM Event."
    items = [components.schemas.DmMediaAttachment]
  }
  components "schemas" "GenericProblem" {
    allOf = [components.schemas.Problem]
    description = "A generic problem with no additional information beyond that provided by the HTTP status code."
  }
  components "schemas" "ResourceNotFoundProblem" {
    description = "A problem that indicates that a given Tweet, User, etc. does not exist."
    allOf = [components.schemas.Problem, object(required(["parameter", "value", "resource_id", "resource_type"]), {
      parameter = string(minLength(1)),
      resource_id = string(),
      resource_type = string(enum("user", "tweet", "media", "list", "space")),
      value = string(description("Value will match the schema of the field."))
    })]
  }
  components "schemas" "AllProjectClientApps" {
    type = "array"
    description = "Client App Rule Counts for all applications in the project"
    items = [components.schemas.AppRulesCount]
  }
  components "schemas" "ClientAppUsage" {
    type = "object"
    description = "Usage per client app"
    properties {
      usage_result_count = integer(format("int32"), description("The number of results returned"))
      client_app_id = string(format("^[0-9]{1,19}$"), description("The unique identifier for this project"))
      usage = array(description("The usage value"), minItems(1), [components.schemas.UsageFields])
    }
  }
  components "schemas" "ClientDisconnectedProblem" {
    description = "Your client has gone away."
    allOf = [components.schemas.Problem]
  }
  components "schemas" "Media" {
    type = "object"
    required = ["type"]
    discriminator {
      propertyName = "type"
      mapping = {
        "animated_gif" = "#/components/schemas/AnimatedGif",
        "photo" = "#/components/schemas/Photo",
        "video" = "#/components/schemas/Video"
      }
    }
    properties {
      type = string()
      width = components.schemas.MediaWidth
      height = components.schemas.MediaHeight
      media_key = components.schemas.MediaKey
    }
  }
  components "schemas" "Tweet" {
    example = {
      author_id = "2244994945",
      created_at = "Wed Jan 06 18:40:40 +0000 2021",
      id = "1346889436626259968",
      text = "Learn how to use the user Tweet timeline and user mention timeline endpoints in the X API v2 to explore Tweet\u2026 https://t.co/56a0vZUx7i"
    }
    required = ["id", "text", "edit_history_tweet_ids"]
    type = "object"
    properties {
      source = string(description("This is deprecated."))
      text = components.schemas.TweetText
      geo = object(description("The location tagged on the Tweet, if the user provided one."), {
        place_id = components.schemas.PlaceId,
        coordinates = components.schemas.Point
      })
      lang = string(description("Language of the Tweet, if detected by X. Returned as a BCP47 language tag."), example("en"))
      organic_metrics = object(description("Organic nonpublic engagement metrics for the Tweet at the time of the request."), required(["impression_count", "retweet_count", "reply_count", "like_count"]), {
        impression_count = integer(description("Number of times this Tweet has been viewed.")),
        like_count = integer(description("Number of times this Tweet has been liked.")),
        reply_count = integer(description("Number of times this Tweet has been replied to.")),
        retweet_count = integer(description("Number of times this Tweet has been Retweeted."))
      })
      non_public_metrics = object(description("Nonpublic engagement metrics for the Tweet at the time of the request."), {
        impression_count = integer(format("int32"), description("Number of times this Tweet has been viewed."))
      })
      promoted_metrics = object(description("Promoted nonpublic engagement metrics for the Tweet at the time of the request."), {
        impression_count = integer(format("int32"), description("Number of times this Tweet has been viewed.")),
        like_count = integer(format("int32"), description("Number of times this Tweet has been liked.")),
        reply_count = integer(format("int32"), description("Number of times this Tweet has been replied to.")),
        retweet_count = integer(format("int32"), description("Number of times this Tweet has been Retweeted."))
      })
      reply_settings = components.schemas.ReplySettingsWithVerifiedUsers
      withheld = components.schemas.TweetWithheld
      created_at = string(format("date-time"), description("Creation time of the Tweet."), example("2021-01-06T18:40:40.000Z"))
      edit_controls = object(required(["is_edit_eligible", "editable_until", "edits_remaining"]), {
        editable_until = string(format("date-time"), description("Time when Tweet is no longer editable."), example("2021-01-06T18:40:40.000Z")),
        edits_remaining = integer(description("Number of times this Tweet can be edited.")),
        is_edit_eligible = boolean(description("Indicates if this Tweet is eligible to be edited."), example(false))
      })
      possibly_sensitive = boolean(description("Indicates if this Tweet contains URLs marked as sensitive, for example content suitable for mature audiences."), example(false))
      conversation_id = components.schemas.TweetId
      scopes = object(description("The scopes for this tweet"), {
        followers = boolean(description("Indicates if this Tweet is viewable by followers without the Tweet ID"), example(false))
      })
      id = components.schemas.TweetId
      author_id = components.schemas.UserId
      context_annotations = array(minItems(1), [components.schemas.ContextAnnotation])
      attachments = object(description("Specifies the type of attachments (if any) present in this Tweet."), {
        media_keys = array(description("A list of Media Keys for each one of the media attachments (if media are attached)."), minItems(1), [components.schemas.MediaKey]),
        media_source_tweet_id = array(description("A list of Posts the media on this Tweet was originally posted in. For example, if the media on a tweet is re-used in another Tweet, this refers to the original, source Tweet.."), minItems(1), [components.schemas.TweetId]),
        poll_ids = array(description("A list of poll IDs (if polls are attached)."), minItems(1), [components.schemas.PollId])
      })
      in_reply_to_user_id = components.schemas.UserId
      edit_history_tweet_ids = array(description("A list of Tweet Ids in this Tweet chain."), minItems(1), [components.schemas.TweetId])
      note_tweet = object(description("The full-content of the Tweet, including text beyond 280 characters."), {
        text = components.schemas.NoteTweetText,
        entities = object({
          mentions = array(minItems(1), [components.schemas.MentionEntity]),
          urls = array(minItems(1), [components.schemas.UrlEntity]),
          cashtags = array(minItems(1), [components.schemas.CashtagEntity]),
          hashtags = array(minItems(1), [components.schemas.HashtagEntity])
        })
      })
      public_metrics = object(description("Engagement metrics for the Tweet at the time of the request."), required(["retweet_count", "reply_count", "like_count", "impression_count", "bookmark_count"]), {
        like_count = integer(description("Number of times this Tweet has been liked.")),
        quote_count = integer(description("Number of times this Tweet has been quoted.")),
        reply_count = integer(description("Number of times this Tweet has been replied to.")),
        retweet_count = integer(description("Number of times this Tweet has been Retweeted.")),
        bookmark_count = integer(format("int32"), description("Number of times this Tweet has been bookmarked.")),
        impression_count = integer(format("int32"), description("Number of times this Tweet has been viewed."))
      })
      entities = components.schemas.FullTextEntities
      referenced_tweets = array(description("A list of Posts this Tweet refers to. For example, if the parent Tweet is a Retweet, a Quoted Tweet or a Reply, it will include the related Tweet referenced to by its parent."), minItems(1), [object(required(["type", "id"]), {
        id = components.schemas.TweetId,
        type = string(enum("retweeted", "quoted", "replied_to"))
      })])
    }
  }
  components "schemas" "DmParticipants" {
    type = "array"
    description = "Participants for the DM Conversation."
    minItems = 2
    maxItems = 49
    items = [components.schemas.UserId]
  }
  components "schemas" "Get2UsersIdPinnedListsResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.List])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "List" {
    type = "object"
    description = "A X List is a curated group of accounts."
    required = ["id", "name"]
    properties {
      created_at = string(format("date-time"))
      description = string()
      follower_count = integer()
      id = components.schemas.ListId
      member_count = integer()
      name = string(description("The name of this List."))
      owner_id = components.schemas.UserId
      private = boolean()
    }
  }
  components "schemas" "LikeComplianceSchema" {
    type = "object"
    required = ["delete"]
    properties {
      delete = components.schemas.UnlikeComplianceSchema
    }
  }
  components "schemas" "PlaceType" {
    type = "string"
    example = "city"
    enum = ["poi", "neighborhood", "city", "admin", "country", "unknown"]
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
  components "schemas" "UploadExpiration" {
    description = "Expiration time of the upload URL."
    example = "2021-01-06T18:40:40.000Z"
    type = "string"
    format = "date-time"
  }
  components "schemas" "UrlEntity" {
    description = "Represent the portion of text recognized as a URL, and its start and end position within the text."
    allOf = [components.schemas.EntityIndicesInclusiveExclusive, components.schemas.UrlFields]
  }
  components "schemas" "UsageFields" {
    type = "object"
    description = "Represents the data for Usage"
    properties {
      date = string(format("date-time"), description("The time period for the usage"), example("2021-01-06T18:40:40.000Z"))
      usage = integer(format("int32"), description("The usage value"))
    }
  }
  components "schemas" "UserComplianceSchema" {
    type = "object"
    required = ["user", "event_at"]
    properties {
      user = object(required(["id"]), {
        id = components.schemas.UserId
      })
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
    }
  }
  components "schemas" "AnimatedGif" {
    allOf = [components.schemas.Media, object({
      preview_image_url = string(format("uri")),
      variants = components.schemas.Variants
    })]
  }
  components "schemas" "Get2TweetsSearchRecentResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.Tweet])
    }
  }
  components "schemas" "TweetHideRequest" {
    type = "object"
    required = ["hidden"]
    properties {
      hidden = boolean()
    }
  }
  components "schemas" "Get2TweetsFirehoseStreamResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "UserTakedownComplianceSchema" {
    required = ["user", "withheld_in_countries", "event_at"]
    type = "object"
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      user = object(required(["id"]), {
        id = components.schemas.UserId
      })
      withheld_in_countries = array(minItems(1), [components.schemas.CountryCode])
    }
  }
  components "schemas" "Get2TweetsSampleStreamResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "ReplySettingsWithVerifiedUsers" {
    pattern = "^[A-Za-z]{1,12}$"
    type = "string"
    description = "Shows who can reply a Tweet. Fields returned are everyone, mentioned_users, subscribers, verified and following."
    enum = ["everyone", "mentionedUsers", "following", "other", "subscribers", "verified"]
  }
  components "schemas" "RulesRequestSummary" {
    oneOf = [object(description("A summary of the results of the addition of user-specified stream filtering rules."), required(["created", "not_created", "valid", "invalid"]), {
      valid = integer(format("int32"), description("Number of valid user-specified stream filtering rules."), example(1)),
      created = integer(format("int32"), description("Number of user-specified stream filtering rules that were created."), example(1)),
      invalid = integer(format("int32"), description("Number of invalid user-specified stream filtering rules."), example(1)),
      not_created = integer(format("int32"), description("Number of user-specified stream filtering rules that were not created."), example(1))
    }), object(required(["deleted", "not_deleted"]), {
      deleted = integer(format("int32"), description("Number of user-specified stream filtering rules that were deleted.")),
      not_deleted = integer(format("int32"), description("Number of user-specified stream filtering rules that were not deleted."))
    })]
  }
  components "schemas" "Space" {
    type = "object"
    required = ["id", "state"]
    properties {
      lang = string(description("The language of the Space."), example("en"))
      participant_count = integer(format("int32"), description("The number of participants in a Space."), example(10))
      speaker_ids = array(description("An array of user ids for people who were speakers in a Space."), [components.schemas.UserId])
      updated_at = string(format("date-time"), description("When the Space was last updated."), example("2021-7-14T04:35:55Z"))
      title = string(description("The title of the Space."), example("Spaces are Awesome"))
      scheduled_start = string(format("date-time"), description("A date time stamp for when a Space is scheduled to begin."), example("2021-07-06T18:40:40.000Z"))
      created_at = string(format("date-time"), description("Creation time of the Space."), example("2021-07-06T18:40:40.000Z"))
      host_ids = array(description("The user ids for the hosts of the Space."), [components.schemas.UserId])
      id = components.schemas.SpaceId
      subscriber_count = integer(format("int32"), description("The number of people who have either purchased a ticket or set a reminder for this Space."), example(10))
      invited_user_ids = array(description("An array of user ids for people who were invited to a Space."), [components.schemas.UserId])
      state = string(description("The current state of the Space."), example("live"), enum("live", "scheduled", "ended"))
      creator_id = components.schemas.UserId
      ended_at = string(format("date-time"), description("End time of the Space."), example("2021-07-06T18:40:40.000Z"))
      topics = array(description("The topics of a Space, as selected by its creator."), [object(description("The X Topic object."), example({
        description = "All about technology",
        id = "848920371311001600",
        name = "Technology"
      }), required(["id", "name"]), {
        description = string(description("The description of the given topic.")),
        id = string(description("An ID suitable for use in the REST API.")),
        name = string(description("The name of the given topic."))
      })])
      is_ticketed = boolean(description("Denotes if the Space is a ticketed Space."), example("false"))
      started_at = string(format("date-time"), description("When the Space was started as a date string."), example("2021-7-14T04:35:55Z"))
    }
  }
  components "schemas" "UserProfileModificationObjectSchema" {
    type = "object"
    required = ["user", "profile_field", "new_value", "event_at"]
    properties {
      profile_field = string()
      user = object(required(["id"]), {
        id = components.schemas.UserId
      })
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      new_value = string()
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
  components "schemas" "DuplicateRuleProblem" {
    description = "The rule you have submitted is a duplicate."
    allOf = [components.schemas.Problem, object({
      value = string(),
      id = string()
    })]
  }
  components "schemas" "Get2SpacesResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.Space])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "InvalidRequestProblem" {
    description = "A problem that indicates this request is invalid."
    allOf = [components.schemas.Problem, object({
      errors = array(minItems(1), [object({
        message = string(),
        parameters = map(array([string()]))
      })])
    })]
  }
  components "schemas" "TweetCreateResponse" {
    type = "object"
    properties {
      data = object(required(["id", "text"]), {
        id = components.schemas.TweetId,
        text = components.schemas.TweetText
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "DmEventId" {
    description = "Unique identifier of a DM Event."
    example = "1146654567674912769"
    pattern = "^[0-9]{1,19}$"
    type = "string"
  }
  components "schemas" "Get2UsersIdBlockingResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.User])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "InvalidRuleProblem" {
    description = "The rule you have submitted is invalid."
    allOf = [components.schemas.Problem]
  }
  components "schemas" "Get2UsersByUsernameUsernameResponse" {
    type = "object"
    properties {
      data = components.schemas.User
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2UsersResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.User])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "MentionFields" {
    description = "Represent the portion of text recognized as a User mention, and its start and end position within the text."
    required = ["username"]
    type = "object"
    properties {
      username = components.schemas.UserName
      id = components.schemas.UserId
    }
  }
  components "schemas" "TweetEditComplianceObjectSchema" {
    type = "object"
    required = ["tweet", "event_at", "initial_tweet_id", "edit_tweet_ids"]
    properties {
      edit_tweet_ids = array(minItems(1), [components.schemas.TweetId])
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      initial_tweet_id = components.schemas.TweetId
      tweet = object(required(["id"]), {
        id = components.schemas.TweetId
      })
    }
  }
  components "schemas" "UserWithheld" {
    type = "object"
    description = "Indicates withholding details for [withheld content](https://help.twitter.com/en/rules-and-policies/tweet-withheld-by-country)."
    required = ["country_codes"]
    properties {
      country_codes = array(description("Provides a list of countries where this content is not available."), minItems(1), uniqueItems(true), [components.schemas.CountryCode])
      scope = string(description("Indicates that the content being withheld is a `user`."), enum("user"))
    }
  }
  components "schemas" "MuteUserRequest" {
    type = "object"
    required = ["target_user_id"]
    properties {
      target_user_id = components.schemas.UserId
    }
  }
  components "schemas" "ReplySettings" {
    type = "string"
    description = "Shows who can reply a Tweet. Fields returned are everyone, mentioned_users, and following."
    enum = ["everyone", "mentionedUsers", "following", "other"]
    pattern = "^[A-Za-z]{1,12}$"
  }
  components "schemas" "DmMediaAttachment" {
    type = "object"
    required = ["media_id"]
    properties {
      media_id = components.schemas.MediaId
    }
  }
  components "schemas" "Error" {
    type = "object"
    required = ["code", "message"]
    properties {
      message = string()
      code = integer(format("int32"))
    }
  }
  components "schemas" "FilteredStreamingTweetResponse" {
    type = "object"
    description = "A Tweet or error that can be returned by the streaming Tweet API. The values returned with a successful streamed Tweet includes the user provided rules that the Tweet matched."
    properties {
      data = components.schemas.Tweet
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      matching_rules = array(description("The list of rules which matched the Tweet"), [object(required(["id"]), {
        id = components.schemas.RuleId,
        tag = components.schemas.RuleTag
      })])
    }
  }
  components "schemas" "Point" {
    type = "object"
    description = "A [GeoJson Point](https://tools.ietf.org/html/rfc7946#section-3.1.2) geometry object."
    required = ["type", "coordinates"]
    properties {
      coordinates = components.schemas.Position
      type = string(example("Point"), enum("Point"))
    }
  }
  components "schemas" "PollId" {
    type = "string"
    description = "Unique identifier of this poll."
    example = "1365059861688410112"
    pattern = "^[0-9]{1,19}$"
  }
  components "schemas" "TweetUnviewableSchema" {
    type = "object"
    required = ["public_tweet_unviewable"]
    properties {
      public_tweet_unviewable = components.schemas.TweetUnviewable
    }
  }
  components "schemas" "UsersRetweetsCreateRequest" {
    type = "object"
    required = ["tweet_id"]
    properties {
      tweet_id = components.schemas.TweetId
    }
  }
  components "schemas" "Get2ListsIdMembersResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.User])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken
      })
    }
  }
  components "schemas" "ListCreateResponse" {
    type = "object"
    properties {
      data = object(description("A X List is a curated group of accounts."), required(["id", "name"]), {
        id = components.schemas.ListId,
        name = string(description("The name of this List."))
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "NextToken" {
    type = "string"
    description = "The next token."
    minLength = 1
  }
  components "schemas" "TweetHideResponse" {
    type = "object"
    properties {
      data = object({
        hidden = boolean()
      })
    }
  }
  components "schemas" "UserScrubGeoSchema" {
    type = "object"
    required = ["scrub_geo"]
    properties {
      scrub_geo = components.schemas.UserScrubGeoObjectSchema
    }
  }
  components "schemas" "UserSearchQuery" {
    type = "string"
    description = "The the search string by which to query for users."
    pattern = "^[A-Za-z0-9_]{1,32}$"
  }
  components "schemas" "Get2ComplianceJobsResponse" {
    type = "object"
    properties {
      meta = object({
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.ComplianceJob])
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "ListDeleteResponse" {
    type = "object"
    properties {
      data = object({
        deleted = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "ListUpdateRequest" {
    type = "object"
    properties {
      name = string(maxLength(25), minLength(1))
      private = boolean()
      description = string(maxLength(100))
    }
  }
  components "schemas" "Oauth1PermissionsProblem" {
    description = "A problem that indicates your client application does not have the required OAuth1 permissions for the requested endpoint."
    allOf = [components.schemas.Problem]
  }
  components "schemas" "UserProfileModificationComplianceSchema" {
    required = ["user_profile_modification"]
    type = "object"
    properties {
      user_profile_modification = components.schemas.UserProfileModificationObjectSchema
    }
  }
  components "schemas" "UsersLikesDeleteResponse" {
    type = "object"
    properties {
      data = object({
        liked = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "UserName" {
    type = "string"
    description = "The X handle (screen name) of this user."
    pattern = "^[A-Za-z0-9_]{1,15}$"
  }
  components "schemas" "Aggregate" {
    type = "integer"
    format = "int32"
    description = "The sum of results returned in this response."
  }
  components "schemas" "TweetComplianceData" {
    description = "Tweet compliance data."
    oneOf = [components.schemas.TweetDeleteComplianceSchema, components.schemas.TweetWithheldComplianceSchema, components.schemas.TweetDropComplianceSchema, components.schemas.TweetUndropComplianceSchema, components.schemas.TweetEditComplianceSchema]
  }
  components "schemas" "UsageCapExceededProblem" {
    description = "A problem that indicates that a usage cap has been exceeded."
    allOf = [components.schemas.Problem, object({
      period = string(enum("Daily", "Monthly")),
      scope = string(enum("Account", "Product"))
    })]
  }
  components "schemas" "Get2UsersIdFollowedListsResponse" {
    type = "object"
    properties {
      meta = object({
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken
      })
      data = array(minItems(1), [components.schemas.List])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2UsersIdMutingResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.User])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "TweetNotice" {
    type = "object"
    required = ["tweet", "event_type", "event_at", "application"]
    properties {
      label_title = string(description("Title/header of the Tweet label"))
      tweet = object(required(["id", "author_id"]), {
        author_id = components.schemas.UserId,
        id = components.schemas.TweetId
      })
      application = string(description("If the label is being applied or removed. Possible values are ‘apply’ or ‘remove’."), example("apply"))
      details = string(description("Information shown on the Tweet label"))
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      event_type = string(description("The type of label on the Tweet"), example("misleading"))
      extended_details_url = string(description("Link to more information about this kind of label"))
    }
  }
  components "schemas" "Get2UsersIdOwnedListsResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.List])
    }
  }
  components "schemas" "MediaKey" {
    type = "string"
    description = "The Media Key identifier for this attachment."
    pattern = "^([0-9]+)_([0-9]+)$"
  }
  components "schemas" "PaginationToken32" {
    minLength = 16
    type = "string"
    description = "A base32 pagination token."
  }
  components "schemas" "UploadUrl" {
    type = "string"
    format = "uri"
    description = "URL to which the user will upload their Tweet or user IDs."
  }
  components "schemas" "Get2TweetsFirehoseStreamLangKoResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2TweetsSearchStreamResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "PollOption" {
    required = ["position", "label", "votes"]
    type = "object"
    description = "Describes a choice in a Poll object."
    properties {
      position = integer(description("Position of this choice in the poll."))
      votes = integer(description("Number of users who voted for this choice."))
      label = components.schemas.PollOptionLabel
    }
  }
  components "schemas" "UserUndeleteComplianceSchema" {
    type = "object"
    required = ["user_undelete"]
    properties {
      user_undelete = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "Get2UsersIdMentionsResponse" {
    type = "object"
    properties {
      meta = object({
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.Tweet])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "MediaWidth" {
    type = "integer"
    description = "The width of the media in pixels."
  }
  components "schemas" "PollOptionLabel" {
    type = "string"
    description = "The text of a poll choice."
    minLength = 1
    maxLength = 25
  }
  components "schemas" "UrlFields" {
    type = "object"
    description = "Represent the portion of text recognized as a URL."
    required = ["url"]
    properties {
      title = string(description("Title of the page the URL points to."), example("Introducing the v2 follow lookup endpoints"))
      unwound_url = string(format("uri"), description("Fully resolved url."), example("https://twittercommunity.com/t/introducing-the-v2-follow-lookup-endpoints/147118"))
      expanded_url = components.schemas.Url
      url = components.schemas.Url
      images = array(minItems(1), [components.schemas.UrlImage])
      display_url = string(description("The URL as displayed in the X client."), example("twittercommunity.com/t/introducing-…"))
      description = string(description("Description of the URL landing page."), example("This is a description of the website."))
      media_key = components.schemas.MediaKey
      status = components.schemas.HttpStatusCode
    }
  }
  components "schemas" "UserProtectComplianceSchema" {
    type = "object"
    required = ["user_protect"]
    properties {
      user_protect = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "Video" {
    allOf = [components.schemas.Media, object({
      public_metrics = object(description("Engagement metrics for the Media at the time of the request."), {
        view_count = integer(format("int32"), description("Number of times this video has been viewed."))
      }),
      variants = components.schemas.Variants,
      duration_ms = integer(),
      non_public_metrics = object(description("Nonpublic engagement metrics for the Media at the time of the request."), {
        playback_25_count = integer(format("int32"), description("Number of users who made it through 25% of the video.")),
        playback_50_count = integer(format("int32"), description("Number of users who made it through 50% of the video.")),
        playback_75_count = integer(format("int32"), description("Number of users who made it through 75% of the video.")),
        playback_0_count = integer(format("int32"), description("Number of users who made it through 0% of the video.")),
        playback_100_count = integer(format("int32"), description("Number of users who made it through 100% of the video."))
      }),
      organic_metrics = object(description("Organic nonpublic engagement metrics for the Media at the time of the request."), {
        playback_0_count = integer(format("int32"), description("Number of users who made it through 0% of the video.")),
        playback_100_count = integer(format("int32"), description("Number of users who made it through 100% of the video.")),
        playback_25_count = integer(format("int32"), description("Number of users who made it through 25% of the video.")),
        playback_50_count = integer(format("int32"), description("Number of users who made it through 50% of the video.")),
        playback_75_count = integer(format("int32"), description("Number of users who made it through 75% of the video.")),
        view_count = integer(format("int32"), description("Number of times this video has been viewed."))
      }),
      preview_image_url = string(format("uri")),
      promoted_metrics = object(description("Promoted nonpublic engagement metrics for the Media at the time of the request."), {
        playback_0_count = integer(format("int32"), description("Number of users who made it through 0% of the video.")),
        playback_100_count = integer(format("int32"), description("Number of users who made it through 100% of the video.")),
        playback_25_count = integer(format("int32"), description("Number of users who made it through 25% of the video.")),
        playback_50_count = integer(format("int32"), description("Number of users who made it through 50% of the video.")),
        playback_75_count = integer(format("int32"), description("Number of users who made it through 75% of the video.")),
        view_count = integer(format("int32"), description("Number of times this video has been viewed."))
      })
    })]
  }
  components "schemas" "EntityIndicesInclusiveInclusive" {
    type = "object"
    description = "Represent a boundary range (start and end index) for a recognized entity (for example a hashtag or a mention). `start` must be smaller than `end`.  The start index is inclusive, the end index is inclusive."
    required = ["start", "end"]
    properties {
      end = integer(description("Index (zero-based) at which position this entity ends.  The index is inclusive."), example(61))
      start = integer(description("Index (zero-based) at which position this entity starts.  The index is inclusive."), example(50))
    }
  }
  components "schemas" "Get2TweetsIdRetweetsResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.Tweet])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "Get2UsersIdTweetsResponse" {
    type = "object"
    properties {
      meta = object({
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.Tweet])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "PaginationToken36" {
    type = "string"
    description = "A base36 pagination token."
    minLength = 1
  }
  components "schemas" "ResourceUnauthorizedProblem" {
    description = "A problem that indicates you are not allowed to see a particular Tweet, User, etc."
    allOf = [components.schemas.Problem, object(required(["value", "resource_id", "resource_type", "section", "parameter"]), {
      parameter = string(),
      resource_id = string(),
      resource_type = string(enum("user", "tweet", "media", "list", "space")),
      section = string(enum("data", "includes")),
      value = string()
    })]
  }
  components "schemas" "Rule" {
    type = "object"
    description = "A user-provided stream filtering rule."
    required = ["value"]
    properties {
      value = components.schemas.RuleValue
      id = components.schemas.RuleId
      tag = components.schemas.RuleTag
    }
  }
  components "schemas" "CashtagEntity" {
    allOf = [components.schemas.EntityIndicesInclusiveExclusive, components.schemas.CashtagFields]
  }
  components "schemas" "Get2TweetsIdLikingUsersResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.User])
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Get2TweetsSearchStreamRulesCountsResponse" {
    type = "object"
    properties {
      data = components.schemas.RulesCount
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Get2SpacesSearchResponse" {
    type = "object"
    properties {
      meta = object({
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.Space])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
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
  components "schemas" "Position" {
    minItems = 2
    maxItems = 2
    items = [number()]
    type = "array"
    description = "A [GeoJson Position](https://tools.ietf.org/html/rfc7946#section-3.1.1) in the format `[longitude,latitude]`."
    example = ["-105.18816086351444", "40.247749999999996"]
  }
  components "schemas" "BookmarkMutationResponse" {
    type = "object"
    properties {
      data = object({
        bookmarked = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
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
  components "schemas" "Get2DmEventsEventIdResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      data = components.schemas.DmEvent
    }
  }
  components "schemas" "ListAddUserRequest" {
    type = "object"
    required = ["user_id"]
    properties {
      user_id = components.schemas.UserId
    }
  }
  components "schemas" "ListPinnedRequest" {
    type = "object"
    required = ["list_id"]
    properties {
      list_id = components.schemas.ListId
    }
  }
  components "schemas" "TweetDeleteComplianceSchema" {
    type = "object"
    required = ["delete"]
    properties {
      delete = components.schemas.TweetComplianceSchema
    }
  }
  components "schemas" "RuleValue" {
    type = "string"
    description = "The filterlang value of the rule."
    example = "coffee -is:retweet"
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
  components "schemas" "UserIdMatchesAuthenticatedUser" {
    type = "string"
    description = "Unique identifier of this User. The value must be the same as the authenticated user."
    example = "2244994945"
  }
  components "schemas" "UsersRetweetsDeleteResponse" {
    type = "object"
    properties {
      data = object({
        retweeted = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "CreatedAt" {
    format = "date-time"
    description = "Creation time of the compliance job."
    example = "2021-01-06T18:40:40.000Z"
    type = "string"
  }
  components "schemas" "Get2UsersMeResponse" {
    type = "object"
    properties {
      data = components.schemas.User
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "MediaId" {
    type = "string"
    description = "The unique identifier of this Media."
    example = "1146654567674912769"
    pattern = "^[0-9]{1,19}$"
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
  components "schemas" "Get2TweetsSample10StreamResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
    }
  }
  components "schemas" "ListId" {
    description = "The unique identifier of this List."
    example = "1146654567674912769"
    pattern = "^[0-9]{1,19}$"
    type = "string"
  }
  components "schemas" "UsersRetweetsCreateResponse" {
    type = "object"
    properties {
      data = object({
        id = components.schemas.TweetId,
        retweeted = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
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
  components "schemas" "TweetUndropComplianceSchema" {
    type = "object"
    required = ["undrop"]
    properties {
      undrop = components.schemas.TweetComplianceSchema
    }
  }
  components "schemas" "UsersFollowingCreateResponse" {
    type = "object"
    properties {
      data = object({
        following = boolean(),
        pending_follow = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "ListMutateResponse" {
    type = "object"
    properties {
      data = object({
        is_member = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Variant" {
    type = "object"
    properties {
      bit_rate = integer(description("The bit rate of the media."))
      content_type = string(description("The content type of the media."))
      url = string(format("uri"), description("The url to the media."))
    }
  }
  components "schemas" "CreateDmConversationRequest" {
    type = "object"
    required = ["conversation_type", "participant_ids", "message"]
    properties {
      participant_ids = components.schemas.DmParticipants
      conversation_type = string(description("The conversation type that is being created."), enum("Group"))
      message = components.schemas.CreateMessageRequest
    }
  }
  components "schemas" "DeleteRulesRequest" {
    description = "A response from deleting user-specified stream filtering rules."
    required = ["delete"]
    type = "object"
    properties {
      delete = object(description("IDs and values of all deleted user-specified stream filtering rules."), {
        ids = array(description("IDs of all deleted user-specified stream filtering rules."), [components.schemas.RuleId]),
        values = array(description("Values of all deleted user-specified stream filtering rules."), [components.schemas.RuleValue])
      })
    }
  }
  components "schemas" "DmEvent" {
    type = "object"
    required = ["id", "event_type"]
    properties {
      participant_ids = array(description("A list of participants for a ParticipantsJoin or ParticipantsLeave event_type."), minItems(1), [components.schemas.UserId])
      sender_id = components.schemas.UserId
      hashtags = array(minItems(1), [components.schemas.HashtagEntity])
      urls = array(minItems(1), [components.schemas.UrlEntityDm])
      created_at = string(format("date-time"))
      dm_conversation_id = components.schemas.DmConversationId
      referenced_tweets = array(description("A list of Posts this DM refers to."), minItems(1), [object(required(["id"]), {
        id = components.schemas.TweetId
      })])
      text = string()
      cashtags = array(minItems(1), [components.schemas.CashtagEntity])
      event_type = string(example("MessageCreate"))
      id = components.schemas.DmEventId
      attachments = object(description("Specifies the type of attachments (if any) present in this DM."), {
        card_ids = array(description("A list of card IDs (if cards are attached)."), minItems(1), [string()]),
        media_keys = array(description("A list of Media Keys for each one of the media attachments (if media are attached)."), minItems(1), [components.schemas.MediaKey])
      })
      mentions = array(minItems(1), [components.schemas.MentionEntity])
    }
  }
  components "schemas" "TweetCount" {
    type = "integer"
    description = "The count for the bucket."
  }
  components "schemas" "User" {
    example = {
      created_at = "2013-12-14T04:35:55Z",
      id = "2244994945",
      name = "X Dev",
      protected = "false",
      username = "TwitterDev"
    }
    required = ["id", "name", "username"]
    type = "object"
    description = "The X User object."
    properties {
      profile_image_url = string(format("uri"), description("The URL to the profile image for this User."))
      subscription_type = string(description("The X Blue subscription type of the user, eg: Basic, Premium, PremiumPlus or None."), enum("Basic", "Premium", "PremiumPlus", "None"))
      name = string(description("The friendly name of this User, as shown on their profile."))
      public_metrics = object(description("A list of metrics for this User."), required(["followers_count", "following_count", "tweet_count", "listed_count"]), {
        followers_count = integer(description("Number of Users who are following this User.")),
        following_count = integer(description("Number of Users this User is following.")),
        like_count = integer(description("The number of likes created by this User.")),
        listed_count = integer(description("The number of lists that include this User.")),
        tweet_count = integer(description("The number of Posts (including Retweets) posted by this User."))
      })
      receives_your_dm = boolean(description("Indicates if you can send a DM to this User"))
      verified = boolean(description("Indicate if this User is a verified X User."))
      verified_type = string(description("The X Blue verified type of the user, eg: blue, government, business or none."), enum("blue", "government", "business", "none"))
      entities = object(description("A list of metadata found in the User's profile description."), {
        description = components.schemas.FullTextEntities,
        url = object(description("Expanded details for the URL specified in the User's profile, with start and end indices."), {
          urls = array(minItems(1), [components.schemas.UrlEntity])
        })
      })
      location = string(description("The location specified in the User's profile, if the User provided one. As this is a freeform value, it may not indicate a valid location, but it may be fuzzily evaluated when performing searches with location queries."))
      id = components.schemas.UserId
      connection_status = array(description("Returns detailed information about the relationship between two users."), [string(description("Type of connection between users."), enum("follow_request_received", "follow_request_sent", "blocking", "followed_by", "following", "muting"))])
      protected = boolean(description("Indicates if this User has chosen to protect their Posts (in other words, if this User's Posts are private)."))
      withheld = components.schemas.UserWithheld
      description = string(description("The text of this User's profile description (also known as bio), if the User provided one."))
      username = components.schemas.UserName
      url = string(description("The URL specified in the User's profile."))
      most_recent_tweet_id = components.schemas.TweetId
      pinned_tweet_id = components.schemas.TweetId
      created_at = string(format("date-time"), description("Creation time of this User."))
    }
  }
  components "schemas" "AddOrDeleteRulesRequest" {
    oneOf = [components.schemas.AddRulesRequest, components.schemas.DeleteRulesRequest]
  }
  components "schemas" "DeleteDmResponse" {
    type = "object"
    properties {
      data = object({
        deleted = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "RuleNoId" {
    type = "object"
    description = "A user-provided stream filtering rule."
    required = ["value"]
    properties {
      value = components.schemas.RuleValue
      tag = components.schemas.RuleTag
    }
  }
  components "schemas" "AddOrDeleteRulesResponse" {
    type = "object"
    description = "A response from modifying user-specified stream filtering rules."
    required = ["meta"]
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      meta = components.schemas.RulesResponseMetadata
      data = array(description("All user-specified stream filtering rules that were created."), [components.schemas.Rule])
    }
  }
  components "schemas" "DownloadExpiration" {
    format = "date-time"
    description = "Expiration time of the download URL."
    example = "2021-01-06T18:40:40.000Z"
    type = "string"
  }
  components "schemas" "TweetEditComplianceSchema" {
    type = "object"
    required = ["tweet_edit"]
    properties {
      tweet_edit = components.schemas.TweetEditComplianceObjectSchema
    }
  }
  components "schemas" "TweetLabelData" {
    description = "Tweet label data."
    oneOf = [components.schemas.TweetNoticeSchema, components.schemas.TweetUnviewableSchema]
  }
  components "schemas" "FullTextEntities" {
    type = "object"
    properties {
      mentions = array(minItems(1), [components.schemas.MentionEntity])
      urls = array(minItems(1), [components.schemas.UrlEntity])
      annotations = array(minItems(1), [{
        description = "Annotation for entities based on the Tweet text.",
        allOf = [components.schemas.EntityIndicesInclusiveInclusive, object(description("Represents the data for the annotation."), {
          type = string(description("Annotation type."), example("Person")),
          normalized_text = string(description("Text used to determine annotation."), example("Barack Obama")),
          probability = number(format("double"), description("Confidence factor for annotation type."), maximum(1))
        })]
      }])
      cashtags = array(minItems(1), [components.schemas.CashtagEntity])
      hashtags = array(minItems(1), [components.schemas.HashtagEntity])
    }
  }
  components "schemas" "Get2UsersIdListMembershipsResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.List])
    }
  }
  components "schemas" "TweetDeleteResponse" {
    type = "object"
    properties {
      data = object(required(["deleted"]), {
        deleted = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "PaginationTokenLong" {
    type = "string"
    description = "A 'long' pagination token."
    minLength = 1
    maxLength = 19
  }
  components "schemas" "RulesCapProblem" {
    description = "You have exceeded the maximum number of rules."
    allOf = [components.schemas.Problem]
  }
  components "schemas" "Trend" {
    type = "object"
    description = "A trend."
    properties {
      trend_name = string(description("Name of the trend."))
      tweet_count = integer(format("int32"), description("Number of Posts in this trend."))
    }
  }
  components "schemas" "CreateComplianceJobRequest" {
    description = "A request to create a new batch compliance job."
    required = ["type"]
    type = "object"
    properties {
      resumable = boolean(description("If true, this endpoint will return a pre-signed URL with resumable uploads enabled."))
      type = string(description("Type of compliance job to list."), enum("tweets", "users"))
      name = components.schemas.ComplianceJobName
    }
  }
  components "schemas" "Get2ComplianceJobsIdResponse" {
    type = "object"
    properties {
      data = components.schemas.ComplianceJob
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Get2DmEventsResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount,
        next_token = components.schemas.NextToken
      })
      data = array(minItems(1), [components.schemas.DmEvent])
    }
  }
  components "schemas" "ConnectionExceptionProblem" {
    description = "A problem that indicates something is wrong with the connection."
    allOf = [components.schemas.Problem, object({
      connection_issue = string(enum("TooManyConnections", "ProvisioningSubscription", "RuleConfigurationIssue", "RulesInvalidIssue"))
    })]
  }
  components "schemas" "Get2SpacesByCreatorIdsResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.Space])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "UserWithheldComplianceSchema" {
    type = "object"
    required = ["user_withheld"]
    properties {
      user_withheld = components.schemas.UserTakedownComplianceSchema
    }
  }
  components "schemas" "CreateAttachmentsMessageRequest" {
    type = "object"
    required = ["attachments"]
    properties {
      text = string(description("Text of the message."), minLength(1))
      attachments = components.schemas.DmAttachments
    }
  }
  components "schemas" "FieldUnauthorizedProblem" {
    description = "A problem that indicates that you are not allowed to see a particular field on a Tweet, User, etc."
    allOf = [components.schemas.Problem, object(required(["resource_type", "field", "section"]), {
      field = string(),
      resource_type = string(enum("user", "tweet", "media", "list", "space")),
      section = string(enum("data", "includes"))
    })]
  }
  components "schemas" "ListUpdateResponse" {
    type = "object"
    properties {
      data = object({
        updated = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "UserSuspendComplianceSchema" {
    type = "object"
    required = ["user_suspend"]
    properties {
      user_suspend = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "UserUnsuspendComplianceSchema" {
    required = ["user_unsuspend"]
    type = "object"
    properties {
      user_unsuspend = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "Url" {
    type = "string"
    format = "uri"
    description = "A validly formatted URL."
    example = "https://developer.twitter.com/en/docs/twitter-api"
  }
  components "schemas" "UsersFollowingDeleteResponse" {
    type = "object"
    properties {
      data = object({
        following = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Get2SpacesIdResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.Space
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Get2UsersIdFollowingResponse" {
    type = "object"
    properties {
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.User])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "TweetDropComplianceSchema" {
    type = "object"
    required = ["drop"]
    properties {
      drop = components.schemas.TweetComplianceSchema
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
  components "schemas" "UserComplianceData" {
    description = "User compliance data."
    oneOf = [components.schemas.UserProtectComplianceSchema, components.schemas.UserUnprotectComplianceSchema, components.schemas.UserDeleteComplianceSchema, components.schemas.UserUndeleteComplianceSchema, components.schemas.UserSuspendComplianceSchema, components.schemas.UserUnsuspendComplianceSchema, components.schemas.UserWithheldComplianceSchema, components.schemas.UserScrubGeoSchema, components.schemas.UserProfileModificationComplianceSchema]
  }
  components "schemas" "UserDeleteComplianceSchema" {
    required = ["user_delete"]
    type = "object"
    properties {
      user_delete = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "ListCreateRequest" {
    required = ["name"]
    type = "object"
    properties {
      name = string(maxLength(25), minLength(1))
      private = boolean(default(false))
      description = string(maxLength(100))
    }
  }
  components "schemas" "PreviousToken" {
    type = "string"
    description = "The previous token."
    minLength = 1
  }
  components "schemas" "ResultCount" {
    type = "integer"
    format = "int32"
    description = "The number of results returned in this response."
  }
  components "schemas" "BookmarkAddRequest" {
    type = "object"
    required = ["tweet_id"]
    properties {
      tweet_id = components.schemas.TweetId
    }
  }
  components "schemas" "ClientForbiddenProblem" {
    description = "A problem that indicates your client is forbidden from making this request."
    allOf = [components.schemas.Problem, object({
      reason = string(enum("official-client-forbidden", "client-not-enrolled")),
      registration_url = string(format("uri"))
    })]
  }
  components "schemas" "Get2DmConversationsWithParticipantIdDmEventsResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.DmEvent])
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "TweetComplianceSchema" {
    type = "object"
    required = ["tweet", "event_at"]
    properties {
      tweet = object(required(["id", "author_id"]), {
        author_id = components.schemas.UserId,
        id = components.schemas.TweetId
      })
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      quote_tweet_id = components.schemas.TweetId
    }
  }
  components "schemas" "UrlEntityDm" {
    description = "Represent the portion of text recognized as a URL, and its start and end position within the text."
    allOf = [components.schemas.EntityIndicesInclusiveExclusive, components.schemas.UrlFields]
  }
  components "schemas" "Get2UsersIdFollowersResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.User])
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
    }
  }
  components "schemas" "Get2UsersIdLikedTweetsResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.Tweet])
    }
  }
  components "schemas" "ListUnpinResponse" {
    type = "object"
    properties {
      data = object({
        pinned = boolean()
      })
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "ResourceUnavailableProblem" {
    description = "A problem that indicates a particular Tweet, User, etc. is not available to you."
    allOf = [components.schemas.Problem, object(required(["parameter", "resource_id", "resource_type"]), {
      parameter = string(minLength(1)),
      resource_id = string(),
      resource_type = string(enum("user", "tweet", "media", "list", "space"))
    })]
  }
  components "schemas" "ComplianceJobType" {
    description = "Type of compliance job to list."
    enum = ["tweets", "users"]
    type = "string"
  }
  components "schemas" "Get2ListsIdResponse" {
    type = "object"
    properties {
      data = components.schemas.List
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2TweetsIdRetweetedByResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      meta = object({
        next_token = components.schemas.NextToken,
        previous_token = components.schemas.PreviousToken,
        result_count = components.schemas.ResultCount
      })
      data = array(minItems(1), [components.schemas.User])
    }
  }
  components "schemas" "TweetUnviewable" {
    type = "object"
    required = ["tweet", "event_at", "application"]
    properties {
      application = string(description("If the label is being applied or removed. Possible values are ‘apply’ or ‘remove’."), example("apply"))
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      tweet = object(required(["id", "author_id"]), {
        author_id = components.schemas.UserId,
        id = components.schemas.TweetId
      })
    }
  }
  components "schemas" "TweetWithheldComplianceSchema" {
    type = "object"
    required = ["withheld"]
    properties {
      withheld = components.schemas.TweetTakedownComplianceSchema
    }
  }
  components "schemas" "Get2TweetsFirehoseStreamLangEnResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
    }
  }
  components "schemas" "NonCompliantRulesProblem" {
    description = "A problem that indicates the user's rule set is not compliant."
    allOf = [components.schemas.Problem]
  }
  components "schemas" "StreamingLikeResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.Like
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Get2TweetsFirehoseStreamLangPtResponse" {
    type = "object"
    properties {
      data = components.schemas.Tweet
      errors = array(minItems(1), [components.schemas.Problem])
      includes = components.schemas.Expansions
    }
  }
  components "schemas" "Get2TweetsIdResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.Tweet
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "TweetCreateRequest" {
    type = "object"
    properties {
      reply = {
        type = "object",
        description = "Tweet information of the Tweet being replied to.",
        required = ["in_reply_to_tweet_id"],
        properties = {
          exclude_reply_user_ids = array(description("A list of User Ids to be excluded from the reply Tweet."), [components.schemas.UserId]),
          in_reply_to_tweet_id = components.schemas.TweetId
        }
      }
      nullcast = boolean(description("Nullcasted (promoted-only) Posts do not appear in the public timeline and are not served to followers."), default(false))
      text = components.schemas.TweetText
      direct_message_deep_link = string(description("Link to take the conversation from the public timeline to a private Direct Message."))
      for_super_followers_only = boolean(description("Exclusive Tweet for super followers."), default(false))
      media = {
        type = "object",
        description = "Media information being attached to created Tweet. This is mutually exclusive from Quote Tweet Id, Poll, and Card URI.",
        required = ["media_ids"],
        properties = {
          media_ids = array(description("A list of Media Ids to be attached to a created Tweet."), maxItems(4), minItems(1), [components.schemas.MediaId]),
          tagged_user_ids = array(description("A list of User Ids to be tagged in the media for created Tweet."), maxItems(10), [components.schemas.UserId])
        }
      }
      quote_tweet_id = components.schemas.TweetId
      reply_settings = string(description("Settings to indicate who can reply to the Tweet."), enum("following", "mentionedUsers", "subscribers"))
      geo = {
        description = "Place ID being attached to the Tweet for geo location.",
        type = "object",
        properties = {
          place_id = string()
        }
      }
      poll = {
        type = "object",
        description = "Poll options for a Tweet with a poll. This is mutually exclusive from Media, Quote Tweet Id, and Card URI.",
        required = ["options", "duration_minutes"],
        properties = {
          duration_minutes = integer(format("int32"), description("Duration of the poll in minutes."), minimum(5), maximum(10080)),
          options = array(maxItems(4), minItems(2), [string(description("The text of a poll choice."), maxLength(25), minLength(1))]),
          reply_settings = string(description("Settings to indicate who can reply to the Tweet."), enum("following", "mentionedUsers"))
        }
      }
      card_uri = string(description("Card Uri Parameter. This is mutually exclusive from Quote Tweet Id, Poll, Media, and Direct Message Deep Link."))
    }
  }
  components "schemas" "HttpStatusCode" {
    type = "integer"
    description = "HTTP Status Code."
    minimum = 100
    maximum = 599
  }
  components "schemas" "Get2TweetsCountsRecentResponse" {
    type = "object"
    properties {
      meta = object({
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        total_tweet_count = components.schemas.Aggregate
      })
      data = array(minItems(1), [components.schemas.SearchCount])
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Get2UsageTweetsResponse" {
    type = "object"
    properties {
      errors = array(minItems(1), [components.schemas.Problem])
      data = components.schemas.Usage
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
  components "schemas" "End" {
    type = "string"
    format = "date-time"
    description = "The end time of the bucket."
  }
  components "schemas" "Get2LikesSample10StreamResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      data = components.schemas.Like
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Get2TweetsCountsAllResponse" {
    type = "object"
    properties {
      data = array(minItems(1), [components.schemas.SearchCount])
      errors = array(minItems(1), [components.schemas.Problem])
      meta = object({
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId,
        total_tweet_count = components.schemas.Aggregate
      })
    }
  }
  components "schemas" "CreateComplianceJobResponse" {
    type = "object"
    properties {
      data = components.schemas.ComplianceJob
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "schemas" "Place" {
    type = "object"
    required = ["id", "full_name"]
    properties {
      full_name = string(description("The full name of this place."), example("Lakewood, CO"))
      geo = components.schemas.Geo
      id = components.schemas.PlaceId
      name = string(description("The human readable name of this place."), example("Lakewood"))
      place_type = components.schemas.PlaceType
      contained_within = array(minItems(1), [components.schemas.PlaceId])
      country = string(description("The full name of the county in which this place exists."), example("United States"))
      country_code = components.schemas.CountryCode
    }
  }
  components "schemas" "UserUnprotectComplianceSchema" {
    type = "object"
    required = ["user_unprotect"]
    properties {
      user_unprotect = components.schemas.UserComplianceSchema
    }
  }
  components "schemas" "SpaceId" {
    description = "The unique identifier of this Space."
    example = "1SLjjRYNejbKM"
    pattern = "^[a-zA-Z0-9]{1,13}$"
    type = "string"
  }
  components "schemas" "UserComplianceStreamResponse" {
    description = "User compliance stream events."
    oneOf = [object(description("User compliance event."), required(["data"]), {
      data = components.schemas.UserComplianceData
    }), object(required(["errors"]), {
      errors = array(minItems(1), [components.schemas.Problem])
    })]
  }
  components "schemas" "Like" {
    type = "object"
    description = "A Like event, with the liking user and the tweet being liked"
    properties {
      liked_tweet_id = components.schemas.TweetId
      liking_user_id = components.schemas.UserId
      timestamp_ms = integer(format("int32"), description("Timestamp in milliseconds of creation."))
      created_at = string(format("date-time"), description("Creation time of the Tweet."), example("2021-01-06T18:40:40.000Z"))
      id = components.schemas.LikeId
    }
  }
  components "schemas" "Problem" {
    type = "object"
    description = "An HTTP Problem Details object, as defined in IETF RFC 7807 (https://tools.ietf.org/html/rfc7807)."
    required = ["type", "title"]
    discriminator {
      propertyName = "type"
      mapping = {
        "https://api.twitter.com/2/problems/client-disconnected" = "#/components/schemas/ClientDisconnectedProblem",
        "https://api.twitter.com/2/problems/conflict" = "#/components/schemas/ConflictProblem",
        "https://api.twitter.com/2/problems/oauth1-permissions" = "#/components/schemas/Oauth1PermissionsProblem",
        "https://api.twitter.com/2/problems/rule-cap" = "#/components/schemas/RulesCapProblem",
        "about:blank" = "#/components/schemas/GenericProblem",
        "https://api.twitter.com/2/problems/invalid-request" = "#/components/schemas/InvalidRequestProblem",
        "https://api.twitter.com/2/problems/invalid-rules" = "#/components/schemas/InvalidRuleProblem",
        "https://api.twitter.com/2/problems/not-authorized-for-resource" = "#/components/schemas/ResourceUnauthorizedProblem",
        "https://api.twitter.com/2/problems/resource-not-found" = "#/components/schemas/ResourceNotFoundProblem",
        "https://api.twitter.com/2/problems/duplicate-rules" = "#/components/schemas/DuplicateRuleProblem",
        "https://api.twitter.com/2/problems/noncompliant-rules" = "#/components/schemas/NonCompliantRulesProblem",
        "https://api.twitter.com/2/problems/not-authorized-for-field" = "#/components/schemas/FieldUnauthorizedProblem",
        "https://api.twitter.com/2/problems/operational-disconnect" = "#/components/schemas/OperationalDisconnectProblem",
        "https://api.twitter.com/2/problems/resource-unavailable" = "#/components/schemas/ResourceUnavailableProblem",
        "https://api.twitter.com/2/problems/unsupported-authentication" = "#/components/schemas/UnsupportedAuthenticationProblem",
        "https://api.twitter.com/2/problems/client-forbidden" = "#/components/schemas/ClientForbiddenProblem",
        "https://api.twitter.com/2/problems/disallowed-resource" = "#/components/schemas/DisallowedResourceProblem",
        "https://api.twitter.com/2/problems/streaming-connection" = "#/components/schemas/ConnectionExceptionProblem",
        "https://api.twitter.com/2/problems/usage-capped" = "#/components/schemas/UsageCapExceededProblem"
      }
    }
    properties {
      status = integer()
      title = string()
      type = string()
      detail = string()
    }
  }
  components "schemas" "RulesCount" {
    description = "A count of user-provided stream filtering rules at the application and project levels."
    type = "object"
    properties {
      all_project_client_apps = components.schemas.AllProjectClientApps
      cap_per_client_app = integer(format("int32"), description("Cap of number of rules allowed per client application"))
      cap_per_project = integer(format("int32"), description("Cap of number of rules allowed per project"))
      client_app_rules_count = components.schemas.AppRulesCount
      project_rules_count = integer(format("int32"), description("Number of rules for project"))
    }
  }
  components "schemas" "TweetComplianceStreamResponse" {
    description = "Tweet compliance stream events."
    oneOf = [object(description("Compliance event."), required(["data"]), {
      data = components.schemas.TweetComplianceData
    }), object(required(["errors"]), {
      errors = array(minItems(1), [components.schemas.Problem])
    })]
  }
  components "schemas" "ComplianceJob" {
    type = "object"
    required = ["id", "type", "created_at", "upload_url", "download_url", "upload_expires_at", "download_expires_at", "status"]
    properties {
      type = components.schemas.ComplianceJobType
      id = components.schemas.JobId
      status = components.schemas.ComplianceJobStatus
      download_expires_at = components.schemas.DownloadExpiration
      upload_url = components.schemas.UploadUrl
      created_at = components.schemas.CreatedAt
      download_url = components.schemas.DownloadUrl
      name = components.schemas.ComplianceJobName
      upload_expires_at = components.schemas.UploadExpiration
    }
  }
  components "schemas" "ComplianceJobStatus" {
    type = "string"
    description = "Status of a compliance job."
    enum = ["created", "in_progress", "failed", "complete", "expired"]
  }
  components "schemas" "NoteTweetText" {
    description = "The note content of the Tweet."
    example = "Learn how to use the user Tweet timeline and user mention timeline endpoints in the X API v2 to explore Tweet\u2026 https://t.co/56a0vZUx7i"
    type = "string"
  }
  components "schemas" "NewestId" {
    type = "string"
    description = "The newest id in this response."
  }
  components "schemas" "TweetText" {
    description = "The content of the Tweet."
    example = "Learn how to use the user Tweet timeline and user mention timeline endpoints in the X API v2 to explore Tweet\u2026 https://t.co/56a0vZUx7i"
    type = "string"
  }
  components "schemas" "UserScrubGeoObjectSchema" {
    type = "object"
    required = ["user", "up_to_tweet_id", "event_at"]
    properties {
      event_at = string(format("date-time"), description("Event time."), example("2021-07-06T18:40:40.000Z"))
      up_to_tweet_id = components.schemas.TweetId
      user = object(required(["id"]), {
        id = components.schemas.UserId
      })
    }
  }
  components "schemas" "ConflictProblem" {
    description = "You cannot create a new job if one is already in progress."
    allOf = [components.schemas.Problem]
  }
  components "schemas" "Geo" {
    type = "object"
    required = ["type", "bbox", "properties"]
    properties {
      bbox = array(example(["-105.193475", "39.60973", "-105.053164", "39.761974"]), maxItems(4), minItems(4), [number(format("double"), minimum(-180), maximum(180))])
      geometry = components.schemas.Point
      properties = object()
      type = string(enum("Feature"))
    }
  }
  components "schemas" "Get2TweetsSearchAllResponse" {
    type = "object"
    properties {
      includes = components.schemas.Expansions
      meta = object({
        result_count = components.schemas.ResultCount,
        newest_id = components.schemas.NewestId,
        next_token = components.schemas.NextToken,
        oldest_id = components.schemas.OldestId
      })
      data = array(minItems(1), [components.schemas.Tweet])
      errors = array(minItems(1), [components.schemas.Problem])
    }
  }
  components "parameters" "ListExpansionsParameter" {
    name = "expansions"
    in = "query"
    description = "A comma separated list of fields to expand."
    style = "form"
    schema = array(description("The list of fields you can expand for a [List](#List) object. If the field has an ID, it can be expanded into a full object."), example(["owner_id"]), minItems(1), uniqueItems(true), [string(enum("owner_id"))])
  }
  components "parameters" "UsageFieldsParameter" {
    name = "usage.fields"
    in = "query"
    schema = array(description("The fields available for a Usage object."), example(["cap_reset_day", "daily_client_app_usage", "daily_project_usage", "project_cap", "project_id", "project_usage"]), minItems(1), uniqueItems(true), [string(enum("cap_reset_day", "daily_client_app_usage", "daily_project_usage", "project_cap", "project_id", "project_usage"))])
    description = "A comma separated list of Usage fields to display."
    style = "form"
  }
  components "parameters" "DmEventFieldsParameter" {
    in = "query"
    schema = array(description("The fields available for a DmEvent object."), example(["attachments", "created_at", "dm_conversation_id", "entities", "event_type", "id", "participant_ids", "referenced_tweets", "sender_id", "text"]), minItems(1), uniqueItems(true), [string(enum("attachments", "created_at", "dm_conversation_id", "entities", "event_type", "id", "participant_ids", "referenced_tweets", "sender_id", "text"))])
    description = "A comma separated list of DmEvent fields to display."
    style = "form"
    name = "dm_event.fields"
  }
  components "parameters" "MediaFieldsParameter" {
    in = "query"
    description = "A comma separated list of Media fields to display."
    style = "form"
    name = "media.fields"
    schema = array(description("The fields available for a Media object."), example(["alt_text", "duration_ms", "height", "media_key", "non_public_metrics", "organic_metrics", "preview_image_url", "promoted_metrics", "public_metrics", "type", "url", "variants", "width"]), minItems(1), uniqueItems(true), [string(enum("alt_text", "duration_ms", "height", "media_key", "non_public_metrics", "organic_metrics", "preview_image_url", "promoted_metrics", "public_metrics", "type", "url", "variants", "width"))])
  }
  components "parameters" "RulesCountFieldsParameter" {
    name = "rules_count.fields"
    in = "query"
    description = "A comma separated list of RulesCount fields to display."
    style = "form"
    schema = array(description("The fields available for a RulesCount object."), example(["all_project_client_apps", "cap_per_client_app", "cap_per_project", "client_app_rules_count", "project_rules_count"]), minItems(1), uniqueItems(true), [string(enum("all_project_client_apps", "cap_per_client_app", "cap_per_project", "client_app_rules_count", "project_rules_count"))])
  }
  components "parameters" "ComplianceJobFieldsParameter" {
    name = "compliance_job.fields"
    in = "query"
    description = "A comma separated list of ComplianceJob fields to display."
    style = "form"
    schema = array(description("The fields available for a ComplianceJob object."), example(["created_at", "download_expires_at", "download_url", "id", "name", "resumable", "status", "type", "upload_expires_at", "upload_url"]), minItems(1), uniqueItems(true), [string(enum("created_at", "download_expires_at", "download_url", "id", "name", "resumable", "status", "type", "upload_expires_at", "upload_url"))])
  }
  components "parameters" "DmConversationFieldsParameter" {
    description = "A comma separated list of DmConversation fields to display."
    style = "form"
    name = "dm_conversation.fields"
    in = "query"
    schema = array(description("The fields available for a DmConversation object."), example(["id"]), minItems(1), uniqueItems(true), [string(enum("id"))])
  }
  components "parameters" "SpaceExpansionsParameter" {
    name = "expansions"
    in = "query"
    description = "A comma separated list of fields to expand."
    style = "form"
    schema = array(description("The list of fields you can expand for a [Space](#Space) object. If the field has an ID, it can be expanded into a full object."), example(["creator_id", "host_ids", "invited_user_ids", "speaker_ids", "topic_ids"]), minItems(1), uniqueItems(true), [string(enum("creator_id", "host_ids", "invited_user_ids", "speaker_ids", "topic_ids"))])
  }
  components "parameters" "PlaceFieldsParameter" {
    description = "A comma separated list of Place fields to display."
    schema = array(description("The fields available for a Place object."), example(["contained_within", "country", "country_code", "full_name", "geo", "id", "name", "place_type"]), minItems(1), uniqueItems(true), [string(enum("contained_within", "country", "country_code", "full_name", "geo", "id", "name", "place_type"))])
    style = "form"
    name = "place.fields"
    in = "query"
  }
  components "parameters" "LikeExpansionsParameter" {
    name = "expansions"
    in = "query"
    description = "A comma separated list of fields to expand."
    style = "form"
    schema = array(description("The list of fields you can expand for a [Like](#Like) object. If the field has an ID, it can be expanded into a full object."), example(["liked_tweet_id", "liking_user_id"]), minItems(1), uniqueItems(true), [string(enum("liked_tweet_id", "liking_user_id"))])
  }
  components "parameters" "SpaceFieldsParameter" {
    name = "space.fields"
    in = "query"
    description = "A comma separated list of Space fields to display."
    style = "form"
    schema = array(description("The fields available for a Space object."), example(["created_at", "creator_id", "ended_at", "host_ids", "id", "invited_user_ids", "is_ticketed", "lang", "participant_count", "scheduled_start", "speaker_ids", "started_at", "state", "subscriber_count", "title", "topic_ids", "updated_at"]), minItems(1), uniqueItems(true), [string(enum("created_at", "creator_id", "ended_at", "host_ids", "id", "invited_user_ids", "is_ticketed", "lang", "participant_count", "scheduled_start", "speaker_ids", "started_at", "state", "subscriber_count", "title", "topic_ids", "updated_at"))])
  }
  components "parameters" "UserFieldsParameter" {
    name = "user.fields"
    in = "query"
    description = "A comma separated list of User fields to display."
    style = "form"
    schema = array(description("The fields available for a User object."), example(["connection_status", "created_at", "description", "entities", "id", "location", "most_recent_tweet_id", "name", "pinned_tweet_id", "profile_image_url", "protected", "public_metrics", "receives_your_dm", "subscription_type", "url", "username", "verified", "verified_type", "withheld"]), minItems(1), uniqueItems(true), [string(enum("connection_status", "created_at", "description", "entities", "id", "location", "most_recent_tweet_id", "name", "pinned_tweet_id", "profile_image_url", "protected", "public_metrics", "receives_your_dm", "subscription_type", "url", "username", "verified", "verified_type", "withheld"))])
  }
  components "parameters" "LikeFieldsParameter" {
    description = "A comma separated list of Like fields to display."
    style = "form"
    name = "like.fields"
    schema = array(description("The fields available for a Like object."), example(["created_at", "id", "liked_tweet_id", "liking_user_id", "timestamp_ms"]), minItems(1), uniqueItems(true), [string(enum("created_at", "id", "liked_tweet_id", "liking_user_id", "timestamp_ms"))])
    in = "query"
  }
  components "parameters" "DmEventExpansionsParameter" {
    name = "expansions"
    in = "query"
    description = "A comma separated list of fields to expand."
    style = "form"
    schema = array(description("The list of fields you can expand for a [DmEvent](#DmEvent) object. If the field has an ID, it can be expanded into a full object."), example(["attachments.media_keys", "participant_ids", "referenced_tweets.id", "sender_id"]), minItems(1), uniqueItems(true), [string(enum("attachments.media_keys", "participant_ids", "referenced_tweets.id", "sender_id"))])
  }
  components "parameters" "SearchCountFieldsParameter" {
    name = "search_count.fields"
    in = "query"
    description = "A comma separated list of SearchCount fields to display."
    style = "form"
    schema = array(description("The fields available for a SearchCount object."), example(["end", "start", "tweet_count"]), minItems(1), uniqueItems(true), [string(enum("end", "start", "tweet_count"))])
  }
  components "parameters" "TrendFieldsParameter" {
    in = "query"
    description = "A comma separated list of Trend fields to display."
    style = "form"
    schema = array(description("The fields available for a Trend object."), example(["trend_name", "tweet_count"]), minItems(1), uniqueItems(true), [string(enum("trend_name", "tweet_count"))])
    name = "trend.fields"
  }
  components "parameters" "UserExpansionsParameter" {
    schema = array(description("The list of fields you can expand for a [User](#User) object. If the field has an ID, it can be expanded into a full object."), example(["most_recent_tweet_id", "pinned_tweet_id"]), minItems(1), uniqueItems(true), [string(enum("most_recent_tweet_id", "pinned_tweet_id"))])
    style = "form"
    name = "expansions"
    in = "query"
    description = "A comma separated list of fields to expand."
  }
  components "parameters" "TweetExpansionsParameter" {
    in = "query"
    description = "A comma separated list of fields to expand."
    style = "form"
    schema = array(description("The list of fields you can expand for a [Tweet](#Tweet) object. If the field has an ID, it can be expanded into a full object."), example(["attachments.media_keys", "attachments.media_source_tweet", "attachments.poll_ids", "author_id", "edit_history_tweet_ids", "entities.mentions.username", "geo.place_id", "in_reply_to_user_id", "entities.note.mentions.username", "referenced_tweets.id", "referenced_tweets.id.author_id"]), minItems(1), uniqueItems(true), [string(enum("attachments.media_keys", "attachments.media_source_tweet", "attachments.poll_ids", "author_id", "edit_history_tweet_ids", "entities.mentions.username", "geo.place_id", "in_reply_to_user_id", "entities.note.mentions.username", "referenced_tweets.id", "referenced_tweets.id.author_id"))])
    name = "expansions"
  }
  components "parameters" "TopicFieldsParameter" {
    name = "topic.fields"
    in = "query"
    description = "A comma separated list of Topic fields to display."
    style = "form"
    schema = array(description("The fields available for a Topic object."), example(["description", "id", "name"]), minItems(1), uniqueItems(true), [string(enum("description", "id", "name"))])
  }
  components "parameters" "TweetFieldsParameter" {
    name = "tweet.fields"
    in = "query"
    description = "A comma separated list of Tweet fields to display."
    style = "form"
    schema = array(description("The fields available for a Tweet object."), example(["attachments", "author_id", "card_uri", "context_annotations", "conversation_id", "created_at", "edit_controls", "edit_history_tweet_ids", "entities", "geo", "id", "in_reply_to_user_id", "lang", "non_public_metrics", "note_tweet", "organic_metrics", "possibly_sensitive", "promoted_metrics", "public_metrics", "referenced_tweets", "reply_settings", "scopes", "source", "text", "withheld"]), minItems(1), uniqueItems(true), [string(enum("attachments", "author_id", "card_uri", "context_annotations", "conversation_id", "created_at", "edit_controls", "edit_history_tweet_ids", "entities", "geo", "id", "in_reply_to_user_id", "lang", "non_public_metrics", "note_tweet", "organic_metrics", "possibly_sensitive", "promoted_metrics", "public_metrics", "referenced_tweets", "reply_settings", "scopes", "source", "text", "withheld"))])
  }
  components "parameters" "ListFieldsParameter" {
    name = "list.fields"
    in = "query"
    description = "A comma separated list of List fields to display."
    style = "form"
    schema = array(description("The fields available for a List object."), example(["created_at", "description", "follower_count", "id", "member_count", "name", "owner_id", "private"]), minItems(1), uniqueItems(true), [string(enum("created_at", "description", "follower_count", "id", "member_count", "name", "owner_id", "private"))])
  }
  components "parameters" "PollFieldsParameter" {
    name = "poll.fields"
    in = "query"
    description = "A comma separated list of Poll fields to display."
    style = "form"
    schema = array(description("The fields available for a Poll object."), example(["duration_minutes", "end_datetime", "id", "options", "voting_status"]), minItems(1), uniqueItems(true), [string(enum("duration_minutes", "end_datetime", "id", "options", "voting_status"))])
  }
  components "securitySchemes" "BearerToken" {
    scheme = "bearer"
    type = "http"
  }
  components "securitySchemes" "OAuth2UserToken" {
    type = "oauth2"
    flows {
      authorizationCode {
        scopes = {
          "bookmark.read" = "Allows an app to read bookmarked Tweets",
          "like.write" = "Like and un-like Tweets for you.",
          "list.write" = "Create and manage Lists for you.",
          "offline.access" = "App can request refresh token.",
          "users.read" = "Any account you can see, including protected accounts. Any account you can see, including protected accounts.",
          "dm.read" = "All your Direct Messages",
          "list.read" = "Lists, list members, and list followers of lists you’ve created or are a member of, including private lists.",
          "tweet.moderate.write" = "Hide and unhide replies to your Tweets.",
          "block.read" = "Accounts you’ve blocked.",
          "dm.write" = "Send and manage Direct Messages for you",
          "follows.read" = "People who follow you and people who you follow.",
          "like.read" = "Tweets you’ve liked and likes you can view.",
          "tweet.write" = "Tweet and retweet for you.",
          "tweet.read" = "All the Tweets you can see, including Tweets from protected accounts.",
          "bookmark.write" = "Allows an app to create and delete bookmarks",
          "follows.write" = "Follow and unfollow people for you.",
          "mute.read" = "Accounts you’ve muted.",
          "mute.write" = "Mute and unmute accounts for you.",
          "space.read" = "Access all of the Spaces you can see."
        }
        authorizationUrl = "https://api.twitter.com/2/oauth2/authorize"
        tokenUrl = "https://api.twitter.com/2/oauth2/token"
      }
    }
  }
  components "securitySchemes" "UserToken" {
    type = "http"
    scheme = "OAuth"
  }
