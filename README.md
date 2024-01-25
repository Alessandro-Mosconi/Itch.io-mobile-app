## Endpoints OAUTH discovered so far:

- Profile:

   https://itch.io/api/1/me/me
  
- Search any game: 

   https://itch.io/api/1/me/search/games?query=gambetto
   
   and any user (maybe doesn't work?): 
   
   https://itch.io/api/1/me/search/users?query=kenney 
   
   source: https://github.com/itchio/itch.io/issues/289

- Purchases: 

   https://itch.io/api/1/me/my-owned-keys from https://github.com/leafo/itchio-app-old/issues/6


## Features


### Notifications

- Get a notification any time a new Itch.io game goes on sale
- Get a weekly digest of free games available on Itch.io
- Anytime there is a new free game on Itch.io 



## Roadmap

**Plan the UI/UX:**
   - [ ] Use tools like Figma or Adobe XD for designing the initial UI mockups and wireframes.
   - [ ] Conduct a basic usability study to validate the UI/UX design.
   - [ ] Prepare a design system or style guide to maintain consistency in UI elements.

4. **Adopt a Clean Architecture:**
   - [ ] Implement a clean architecture paradigm, such as Uncle Bob's Clean Architecture. This will help in separating concerns, making the code more testable, maintainable, and scalable.
   - [ ] Define layers: Presentation, Domain, and Data. Ensure each layer has distinct responsibilities.

5. **Choose Libraries and Tools:**
   - [ ] **State Management:** Consider using Provider or Riverpod for simpler apps or Bloc for more complex apps requiring advanced state management.
   - [ ] **Networking:** For RESTful API communication, use packages like `http` or `dio`.
   - [ ] **Local Database:** Consider using Hive or SQLite for local data storage.
   - [ ] **UI Components:** Explore Flutter’s rich set of material and Cupertino widgets. For custom styling and responsive layouts, consider using a package like Flutter ScreenUtil.
   - [ ] **Version Control:** Use Git for version control, combined with GitHub or GitLab for online repository hosting.

6. **Develop MVP Features:**
   - [ ] Start with basic features: user authentication, game browsing interface, and basic navigation.
   - [ ] Implement user authentication using Firebase Authentication.
   - [ ] Develop screens for browsing games, integrating the Itch.io API if available, or scraping data as needed.

7. **Integrate Firebase:**
   - [ ] Set up Firebase project and integrate it with your Flutter app.
   - [ ] Use Firestore for real-time database needs and Cloud Functions for any server-side logic.
   - [ ] Implement Firebase Cloud Messaging (FCM) for push notifications.

8. **Iterative Testing and Development:**
   - [ ] Write unit and widget tests as you develop features. Consider using the `flutter_test` package.
   - [ ] Regularly test the app on different devices and screen sizes.
   - [ ] Use Flutter’s hot reload feature for quick testing during development.

9. **Continuous Integration/Continuous Deployment (CI/CD):**
   - [ ] Set up CI/CD pipelines using tools like GitHub Actions or GitLab CI.
   - [ ] Automate testing and deployment processes to ensure code quality and streamline deployment.

10. **Feedback Loop and Iteration:**
    - [ ] After deploying the MVP, collect user feedback through surveys or in-app analytics. **REDDIT** ?
    - [ ] Use this feedback to iteratively improve the app, adding features and refining the user experience.

11. **Roadmap for Future Development:**
    - [ ] Plan for additional features post-MVP like GIF commenting, jam participation, and home screen widgets.
    - [ ] Continuously monitor user feedback and app performance to guide future development phases.


## Itch.io API documentation CHATGPT resume

In summary, your approach should involve setting up OAuth for user authentication, understanding and utilizing the server-side and JavaScript APIs for specific functionalities, and ensuring all interactions are secure. Given your proficiency in software engineering and your choice of Flutter for app development, integrating these aspects of the Itch.io API will significantly enhance your app’s capabilities and user experience.

### **Understanding the Itch.io API**

The Itch.io API provides various functionalities, including a server-side API, OAuth applications, JavaScript API, and RSS feeds. These enable interactions such as authenticating users, retrieving user information, and integrating purchase buttons or widgets on your site.

https://itch.io/docs/api/overview

#### 1. Server-side API
- **Functionality**: This API allows communication with your Itch.io account using an API key to make queries and changes.
- **Approach & Advice**: 
  - **Authentication**: Use the API key for secure server-side operations, like validating user purchases or accessing user-specific data.
  - **Data Handling**: Efficiently manage data retrieval and updates, ensuring synchronization with your app's user interface.
  - **Security**: Ensure all server communications are done over HTTPS to prevent data breaches.

#### 2. OAuth Applications
- **Functionality**: Enables making requests to the Itch.io API on behalf of another user.
- **Approach & Advice**: 
  - **Registration**: Register an OAuth application in your Itch.io settings to get a client ID.
  - **User Permissions**: Handle user authorization carefully, ensuring transparent permission requests and secure handling of tokens.
  - **Scopes**: Be judicious with scope requests; only request what you need for the functionality of your app.
  - **Redirect URIs**: Ensure the redirect URIs are set correctly for seamless user experience and security.

#### 3. JavaScript API
- **Functionality**: Allows embedding a custom buy button on your site.
- **Approach & Advice**: 
  - **Integration in Web Views**: If your Flutter app includes web view components, use the JavaScript API to embed purchase buttons.
  - **Cross-Platform Compatibility**: Ensure that embedded buttons are responsive and compatible across different screen sizes and platforms.
  - **User Experience**: Make sure the purchase process is smooth and integrates well with the overall design of your app.

#### 4. Widget API
- **Functionality**: Provides an `iframe` based HTML snippet that can be embedded into your existing page for projects you control.
- **Approach & Advice**: 
  - **Customization**: Customize the widget to fit the style and theme of your app.
  - **Placement**: Choose strategic places within your app for widget placement to enhance user engagement without being intrusive.
  - **Performance**: Monitor the performance impact of widgets, especially in terms of loading times and responsiveness.

#### 5. RSS Feeds
- **Functionality**: Offers RSS feeds for new games, featured games, and active sales.
- **Approach & Advice**: 
  - **Content Updates**: Use these feeds to provide users with the latest information from Itch.io directly in your app.
  - **Parsing and Display**: Implement an RSS parser to fetch and display feed content in a user-friendly manner.
  - **User Preferences**: Allow users to customize what feeds they are interested in to enhance personalization.

By segmenting the API functionalities, you can focus on integrating each part effectively based on your app's needs. Each section requires a tailored approach to ensure seamless integration and optimal user experience. Keep in mind the best practices in security, user authorization, and data handling while working with these APIs.


### **Setting Up OAuth Applications**
For actions that require user authentication or actions on behalf of a user, you need to set up an OAuth application on Itch.io. This involves registering your application in the user settings, obtaining a client ID, and defining the required scopes and redirect URIs.

### **Integrating Server-Side API**
The server-side API allows you to communicate with your Itch.io account via an API key. This is essential for actions like user authentication, accessing purchase information, or other server-side functionalities.

### **Utilizing the JavaScript API**: 
If you plan to include web-based functionalities or embed custom purchase buttons, the JavaScript API will be crucial. It allows embedding game purchase buttons directly into web pages, which could be a significant feature for your app, especially if it includes a web view component.

### **Implementing RSS Feeds**

For real-time updates on new games, featured games, and active sales, leveraging the RSS feeds provided by Itch.io can be a smart approach. These feeds can be integrated into your app to provide users with the latest information directly from Itch.io.

### **Handling API Requests**

When making API requests, especially in the context of OAuth, it's important to handle the authorization step correctly. This involves redirecting users to the Itch.io OAuth page, handling permissions, and securely retrieving access tokens.

### **Security Considerations**

Ensure that all API interactions, especially those involving user data and authentication, are secure. This includes using HTTPS for your OAuth Authorization callback page and being cautious with the scopes you request.







## Document Design 

[Document Design](DD.md)

# Link utili 

- https://itch.io/docs/api/overview

## Messaggi da telegram:

I used both **Riverpod** and Bloc and they are very valid libraries but Riverpod was reworked like 1 month ago and I still need to try it

Also one clean way to structure your Flutter app is the clean architecture paradigm, although I don't see the point of also implementing usecases the division between repository, presentation layer and feature oriented directories really hits the spot https://youtu.be/7V_P6dovixg?feature=shared

