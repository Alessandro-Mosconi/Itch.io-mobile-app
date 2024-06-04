
### Access OAuthService in Widgets

Now, anywhere in your app where you need to access the `OAuthService`, you can do so with `Provider.of<OAuthService>(context)` or `Consumer<OAuthService>`. For example, if you have a login button, you could use:

```dart
ElevatedButton(
  onPressed: () {
    // Accessing the OAuthService from the provider to start the OAuth process
    Provider.of<OAuthService>(context, listen: false).startOAuth();
  },
  child: Text('Login'),
)
```

### Listen for Changes and Access Token

If you need to react to changes in the access token (for example, updating the UI upon successful login), you might consider extending `OAuthService` with `ChangeNotifier` and calling `notifyListeners()` when the access token changes. Then, use a `Consumer<OAuthService>` widget to rebuild parts of your UI in response to these changes.



## Firebase stuff 


Firebase functions can be triggered by HTTP requests or scheduled to run at specific time:

  - HTTP reqs:
    - 
    - 
  - scheduled: 
    - 
    - 



Firebase Cloud Messaging (FCM)

stuff like firebase console -> select the projet -> project settings -> your apps ->  setup for flutter is necessary! 


Remember to update always the dependencies in `package.json` and always `npm install`  

```xml
"dependencies": {
    "firebase-admin": "^10.0.0",
    "firebase-functions": "^3.15.0",
    "node-fetch": "^2.6.1",
    "rss-parser": "^3.12.0" 
  },
```

the dependencies! 


To deploy a function:

```bash
firebase deploy --only functions
``` 

but always test locally: 

```bash
firebase emulators:start
```

# Graph architecture

```mermaid
graph LR
    subgraph HelperClasses
        direction TB
        I[Game.dart]
        J[PurchaseGame.dart]
        K[SavedSearch.dart]
        L[User.dart]
    end

    subgraph Providers
        direction TB
        E[page_provider.dart]
        F[theme_notifier.dart]
    end

    subgraph Services
        direction TB
        C[notification_service.dart]
        D[oauth_service.dart]
    end

    subgraph Views
        direction TB
        G[auth_or_home_page.dart]
        M[auth_page.dart]
        N[bookmark_page.dart]
        O[developed_games_page.dart]
        P[favorite_page.dart]
        Q[game_webview_page.dart]
        R[home_page.dart]
        S[main_view.dart]
        T[profile_page.dart]
        U[purchased_games_page.dart]
        V[search_page.dart]
        W[settings_page.dart]
    end

    subgraph Widgets
        direction TB
        X[bottom_navigation_bar.dart]
        Y[custom_app_bar.dart]
        Z[game_tile.dart]
    end

    %% Relationships
    G -->|Uses| M
    G -->|Uses| S
    S -->|Uses| N
    S -->|Uses| P
    S -->|Uses| Q
    S -->|Uses| R
    S -->|Uses| T
    S -->|Uses| U
    S -->|Uses| V
    S -->|Uses| W
    S -->|Contains| X
    S -->|Contains| Y
    S -->|Contains| Z
    Z -->|Uses| I
    Q -->|Imports| I

```

# Old deprecated graph

```mermaid
graph LR
    A[main.dart] -->|Entry Point| B[MyApp]
    B --> C[ProviderApp]
    C --> D[OAuthService Initialization]
    C --> E[ChangeNotifierProvider]
    E --> F[MaterialApp]
    F --> G[MyHomePage]

    subgraph Pages
        G --> H[HomePage]
        G --> I[SearchPage]
        G --> J[BookmarksPage]
        G --> K[ProfilePage]
    end

    subgraph Firebase and Notifications
        A --> L[Firebase Initialization]
        A --> M[Notification Setup]
        M --> N[Request Permissions]
        M --> O[Initialize Local Notifications]
        M --> P[Setup Firebase Messaging Listeners]
        P --> Q[Handle Background Messages]
        P --> R[Show Notifications]
    end
```

### 03 06 2024

Component-Based Design:

SearchBar Component: Handles the search bar with input and filter options.
FilterPopup Component: Handles the display and selection of filters.
FilterRowWidget Component: Displays individual filter options as chips.
ResponsiveGridList Component: Switches between grid and list layouts based on screen width.
Initialization:

_initializePage Method: Fetches filters and tabs, then initializes the state.
_initializeTabAndFilters Method: Sets up initial tab and filters if provided.
_initializeSearchResults Method: Initializes the search results to default values.
Fetching Data:

_fetchFilters, _fetchTabs, _fetchSearchResults, _fetchTabResults: Methods to fetch data from the API and database.
State Management:

_filterMap Method: Converts filter strings into a map of selected filters.
_showFilterPopup Method: Displays the filter selection dialog.
Search and Tabs:

_performSearch Method: Performs a search based on user input.
_changeTab Method: Changes the tab and updates the results.
_saveSearch Method: Saves the current search criteria to the database.
UI Rendering:

_buildSearchBar Method: Renders the search bar using the SearchBar component.
_buildTabsPage Method: Renders the tabs and their content.
_buildSearchPage Method: Renders the search results.
_buildTabPage Method: Renders the content of each tab.



