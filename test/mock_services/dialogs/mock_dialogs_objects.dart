

final List<String> mockDialogsJson = ['{"id":180,"chat_type":{"id":1,"name":"Test dialog","description":"Dialog between two users","p2p":1,"secure":0,"readonly":0,"picture":"","sort":1},"user":{"id":20,"email":"andreypa@cashalot.co","last_access":"2023-07-17T03:54:39.000000Z","banned":false,"staff":{"id":11397,"firstname":"Ivan","lastname":"Ivanov","middlename":"Sergeevich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79084418489","email":"andreypa@cashalot.co","birthdate":"1976-02-29","avatar":null,"user_id":20}},"users":[{"id":20,"email":"andreypa@cashalot.co","last_access":"2023-07-17T03:54:39.000000Z","banned":false,"staff":{"id":11397,"firstname":"Ivan","lastname":"Ivanov","middlename":"Sergeevich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79084418489","email":"andreypa@cashalot.co","birthdate":"1976-02-29","avatar":null,"user_id":20}},{"id":40,"email":"eskov@cashalot.co","last_access":"2023-07-17T03:55:45.000000Z","banned":false,"staff":{"id":11464,"firstname":"Dmitriy","lastname":"Ivanov","middlename":"Dmitrievich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79140774664","email":"eskov@cashalot.co","birthdate":"1992-03-18","avatar":null,"user_id":40}}],"chat_users":[{"chat_id":180,"user_id":20,"chat_user_role_id":1,"active":true,"user":{"id":20,"email":"andreypa@cashalot.co","last_access":"2023-07-17T03:54:39.000000Z","banned":false,"staff":{"id":11397,"firstname":"Ivan","lastname":"Ivanov","middlename":"Sergeevich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79084418489","email":"andreypa@cashalot.co","birthdate":"1976-02-29","avatar":null,"user_id":20}}},{"chat_id":180,"user_id":40,"chat_user_role_id":2,"active":true,"user":{"id":40,"email":"eskov@cashalot.co","last_access":"2023-07-17T03:55:45.000000Z","banned":false,"staff":{"id":11464,"firstname":"Dmitriy","lastname":"Ivanov","middlename":"Dmitrievich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79140774664","email":"eskov@cashalot.co","birthdate":"1992-03-18","avatar":null,"user_id":40}}}],"name":"Dialog between two users","description":"Not specified","is_closed":0,"is_public":0,"picture":"","message":{"id":2207,"chat_id":180,"user_id":40,"parent_id":null,"message":"44","parent":null,"file":null,"statuses":[{"id":4805,"chat_id":180,"user_id":20,"chat_message_id":2207,"chat_message_status_id":3,"created_at":"2023-07-13T00:57:22.000000Z","updated_at":"2023-07-13T00:58:50.000000Z"},{"id":4806,"chat_id":180,"user_id":40,"chat_message_id":2207,"chat_message_status_id":4,"created_at":"2023-07-13T00:57:23.000000Z","updated_at":"2023-07-13T00:57:24.000000Z"}],"created_at":"2023-07-13T00:57:22.000000Z","updated_at":"2023-07-13T00:57:22.000000Z"},"message_count":220,"created_at":"2022-11-28T01:40:27.000000Z","updated_at":"2022-11-28T01:40:27.000000Z"}'];
final String mockReceivedDialog = '{"id":182,"chat_type":{"id":1,"name":"Test dialog","description":"Dialog between two users","p2p":1,"secure":0,"readonly":0,"picture":"","sort":1},"user":{"id":20,"email":"andreypa@cashalot.co","last_access":"2023-07-17T03:54:39.000000Z","banned":false,"staff":{"id":11397,"firstname":"Ivan","lastname":"Ivanov","middlename":"Sergeevich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79084418489","email":"andreypa@cashalot.co","birthdate":"1976-02-29","avatar":null,"user_id":20}},"users":[{"id":20,"email":"andreypa@cashalot.co","last_access":"2023-07-17T03:54:39.000000Z","banned":false,"staff":{"id":11397,"firstname":"Ivan","lastname":"Ivanov","middlename":"Sergeevich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79084418489","email":"andreypa@cashalot.co","birthdate":"1976-02-29","avatar":null,"user_id":20}},{"id":40,"email":"eskov@cashalot.co","last_access":"2023-07-17T03:55:45.000000Z","banned":false,"staff":{"id":11464,"firstname":"Dmitriy","lastname":"Ivanov","middlename":"Dmitrievich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79140774664","email":"eskov@cashalot.co","birthdate":"1992-03-18","avatar":null,"user_id":40}}],"chat_users":[{"chat_id":180,"user_id":20,"chat_user_role_id":1,"active":true,"user":{"id":20,"email":"andreypa@cashalot.co","last_access":"2023-07-17T03:54:39.000000Z","banned":false,"staff":{"id":11397,"firstname":"Ivan","lastname":"Ivanov","middlename":"Sergeevich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79084418489","email":"andreypa@cashalot.co","birthdate":"1976-02-29","avatar":null,"user_id":20}}},{"chat_id":180,"user_id":40,"chat_user_role_id":2,"active":true,"user":{"id":40,"email":"eskov@cashalot.co","last_access":"2023-07-17T03:55:45.000000Z","banned":false,"staff":{"id":11464,"firstname":"Dmitriy","lastname":"Ivanov","middlename":"Dmitrievich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79140774664","email":"eskov@cashalot.co","birthdate":"1992-03-18","avatar":null,"user_id":40}}}],"name":"Dialog between two users","description":"Not specified","is_closed":0,"is_public":0,"picture":"","message":{"id":2207,"chat_id":180,"user_id":40,"parent_id":null,"message":"44","parent":null,"file":null,"statuses":[{"id":4805,"chat_id":180,"user_id":20,"chat_message_id":2207,"chat_message_status_id":3,"created_at":"2023-07-13T00:57:22.000000Z","updated_at":"2023-07-13T00:58:50.000000Z"},{"id":4806,"chat_id":180,"user_id":40,"chat_message_id":2207,"chat_message_status_id":4,"created_at":"2023-07-13T00:57:23.000000Z","updated_at":"2023-07-13T00:57:24.000000Z"}],"created_at":"2023-07-13T00:57:22.000000Z","updated_at":"2023-07-13T00:57:22.000000Z"},"message_count":220,"created_at":"2022-11-28T01:40:27.000000Z","updated_at":"2022-11-28T01:40:27.000000Z"}';

final List<String> mockDialogsWithNewChatUserJson = ['{"id":180,"chat_type":{"id":1,"name":"Test dialog","description":"Dialog between two users","p2p":1,"secure":0,"readonly":0,"picture":"","sort":1},"user":{"id":20,"email":"andreypa@cashalot.co","last_access":"2023-07-17T03:54:39.000000Z","banned":false,"staff":{"id":11397,"firstname":"Ivan","lastname":"Ivanov","middlename":"Sergeevich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79084418489","email":"andreypa@cashalot.co","birthdate":"1976-02-29","avatar":null,"user_id":20}},"users":[{"id":20,"email":"andreypa@cashalot.co","last_access":"2023-07-17T03:54:39.000000Z","banned":false,"staff":{"id":11397,"firstname":"Ivan","lastname":"Ivanov","middlename":"Sergeevich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79084418489","email":"andreypa@cashalot.co","birthdate":"1976-02-29","avatar":null,"user_id":20}},{"id":40,"email":"eskov@cashalot.co","last_access":"2023-07-17T03:55:45.000000Z","banned":false,"staff":{"id":11464,"firstname":"Dmitriy","lastname":"Ivanov","middlename":"Dmitrievich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79140774664","email":"eskov@cashalot.co","birthdate":"1992-03-18","avatar":null,"user_id":40}}],"chat_users":[{"chat_id":180,"user_id":20,"chat_user_role_id":1,"active":true,"user":{"id":20,"email":"andreypa@cashalot.co","last_access":"2023-07-17T03:54:39.000000Z","banned":false,"staff":{"id":11397,"firstname":"Ivan","lastname":"Ivanov","middlename":"Sergeevich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79084418489","email":"andreypa@cashalot.co","birthdate":"1976-02-29","avatar":null,"user_id":20}}}, {"chat_id":180,"user_id":20,"chat_user_role_id":1,"active":true,"user":{"id":20,"email":"andreypa@cashalot.co","last_access":"2023-07-17T03:54:39.000000Z","banned":false,"staff":{"id":11397,"firstname":"Ivan","lastname":"Ivanov","middlename":"Sergeevich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79084418489","email":"andreypa@cashalot.co","birthdate":"1976-02-29","avatar":null,"user_id":20}}},{"chat_id":180,"user_id":40,"chat_user_role_id":2,"active":true,"user":{"id":40,"email":"eskov@cashalot.co","last_access":"2023-07-17T03:55:45.000000Z","banned":false,"staff":{"id":11464,"firstname":"Dmitriy","lastname":"Ivanov","middlename":"Dmitrievich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79140774664","email":"eskov@cashalot.co","birthdate":"1992-03-18","avatar":null,"user_id":40}}}],"name":"Dialog between two users","description":"Not specified","is_closed":0,"is_public":0,"picture":"","message":{"id":2207,"chat_id":180,"user_id":40,"parent_id":null,"message":"44","parent":null,"file":null,"statuses":[{"id":4805,"chat_id":180,"user_id":20,"chat_message_id":2207,"chat_message_status_id":3,"created_at":"2023-07-13T00:57:22.000000Z","updated_at":"2023-07-13T00:58:50.000000Z"},{"id":4806,"chat_id":180,"user_id":40,"chat_message_id":2207,"chat_message_status_id":4,"created_at":"2023-07-13T00:57:23.000000Z","updated_at":"2023-07-13T00:57:24.000000Z"}],"created_at":"2023-07-13T00:57:22.000000Z","updated_at":"2023-07-13T00:57:22.000000Z"},"message_count":220,"created_at":"2022-11-28T01:40:27.000000Z","updated_at":"2022-11-28T01:40:27.000000Z"}'];
final List<String> mockDialogsWithRemovedChatUserJson = ['{"id":180,"chat_type":{"id":1,"name":"Test dialog","description":"Dialog between two users","p2p":1,"secure":0,"readonly":0,"picture":"","sort":1},"user":{"id":20,"email":"andreypa@cashalot.co","last_access":"2023-07-17T03:54:39.000000Z","banned":false,"staff":{"id":11397,"firstname":"Ivan","lastname":"Ivanov","middlename":"Sergeevich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79084418489","email":"andreypa@cashalot.co","birthdate":"1976-02-29","avatar":null,"user_id":20}},"users":[{"id":20,"email":"andreypa@cashalot.co","last_access":"2023-07-17T03:54:39.000000Z","banned":false,"staff":{"id":11397,"firstname":"Ivan","lastname":"Ivanov","middlename":"Sergeevich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79084418489","email":"andreypa@cashalot.co","birthdate":"1976-02-29","avatar":null,"user_id":20}},{"id":40,"email":"eskov@cashalot.co","last_access":"2023-07-17T03:55:45.000000Z","banned":false,"staff":{"id":11464,"firstname":"Dmitriy","lastname":"Ivanov","middlename":"Dmitrievich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79140774664","email":"eskov@cashalot.co","birthdate":"1992-03-18","avatar":null,"user_id":40}}],"chat_users":[{"chat_id":180,"user_id":40,"chat_user_role_id":2,"active":true,"user":{"id":40,"email":"eskov@cashalot.co","last_access":"2023-07-17T03:55:45.000000Z","banned":false,"staff":{"id":11464,"firstname":"Dmitriy","lastname":"Ivanov","middlename":"Dmitrievich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79140774664","email":"eskov@cashalot.co","birthdate":"1992-03-18","avatar":null,"user_id":40}}}],"name":"Dialog between two users","description":"Not specified","is_closed":0,"is_public":0,"picture":"","message":{"id":2207,"chat_id":180,"user_id":40,"parent_id":null,"message":"44","parent":null,"file":null,"statuses":[{"id":4805,"chat_id":180,"user_id":20,"chat_message_id":2207,"chat_message_status_id":3,"created_at":"2023-07-13T00:57:22.000000Z","updated_at":"2023-07-13T00:58:50.000000Z"},{"id":4806,"chat_id":180,"user_id":40,"chat_message_id":2207,"chat_message_status_id":4,"created_at":"2023-07-13T00:57:23.000000Z","updated_at":"2023-07-13T00:57:24.000000Z"}],"created_at":"2023-07-13T00:57:22.000000Z","updated_at":"2023-07-13T00:57:22.000000Z"},"message_count":220,"created_at":"2022-11-28T01:40:27.000000Z","updated_at":"2022-11-28T01:40:27.000000Z"}'];
final List<String> dialogsWithUpdatedLastMessageJson = ['{"id":180,"chat_type":{"id":1,"name":"Test dialog","description":"Dialog between two users","p2p":1,"secure":0,"readonly":0,"picture":"","sort":1},"user":{"id":20,"email":"andreypa@cashalot.co","last_access":"2023-07-17T03:54:39.000000Z","banned":false,"staff":{"id":11397,"firstname":"Ivan","lastname":"Ivanov","middlename":"Sergeevich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79084418489","email":"andreypa@cashalot.co","birthdate":"1976-02-29","avatar":null,"user_id":20}},"users":[{"id":20,"email":"andreypa@cashalot.co","last_access":"2023-07-17T03:54:39.000000Z","banned":false,"staff":{"id":11397,"firstname":"Ivan","lastname":"Ivanov","middlename":"Sergeevich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79084418489","email":"andreypa@cashalot.co","birthdate":"1976-02-29","avatar":null,"user_id":20}},{"id":40,"email":"eskov@cashalot.co","last_access":"2023-07-17T03:55:45.000000Z","banned":false,"staff":{"id":11464,"firstname":"Dmitriy","lastname":"Ivanov","middlename":"Dmitrievich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79140774664","email":"eskov@cashalot.co","birthdate":"1992-03-18","avatar":null,"user_id":40}}],"chat_users":[{"chat_id":180,"user_id":20,"chat_user_role_id":1,"active":true,"user":{"id":20,"email":"andreypa@cashalot.co","last_access":"2023-07-17T03:54:39.000000Z","banned":false,"staff":{"id":11397,"firstname":"Ivan","lastname":"Ivanov","middlename":"Sergeevich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79084418489","email":"andreypa@cashalot.co","birthdate":"1976-02-29","avatar":null,"user_id":20}}},{"chat_id":180,"user_id":40,"chat_user_role_id":2,"active":true,"user":{"id":40,"email":"eskov@cashalot.co","last_access":"2023-07-17T03:55:45.000000Z","banned":false,"staff":{"id":11464,"firstname":"Dmitriy","lastname":"Ivanov","middlename":"Dmitrievich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79140774664","email":"eskov@cashalot.co","birthdate":"1992-03-18","avatar":null,"user_id":40}}}],"name":"Dialog between two users","description":"Not specified","is_closed":0,"is_public":0,"picture":"","message":{"id": 2224,"chat_id": 180,"user_id": 40,"parent_id": null,"message": "66","parent": null,"file": null,"statuses": [{"id": 4799,"chat_id": 236,"user_id": 40,"chat_message_id": 2205,"chat_message_status_id": 4,"created_at": "2023-07-13T00:14:53.000000Z","updated_at": "2023-07-13T00:14:54.000000Z"},{"id": 4800,"chat_id": 236,"user_id": 67,"chat_message_id": 2205,"chat_message_status_id": 3,"created_at": "2023-07-13T00:14:53.000000Z","updated_at": "2023-07-13T00:21:55.000000Z"},{"id": 4801,"chat_id": 236,"user_id": 68,"chat_message_id": 2205,"chat_message_status_id": 3,"created_at": "2023-07-13T00:14:53.000000Z","updated_at": "2023-07-13T00:21:56.000000Z"}],"created_at": "2023-07-13T00:14:53.000000Z","updated_at": "2023-07-13T00:14:53.000000Z"},"message_count":220,"created_at":"2022-11-28T01:40:27.000000Z","updated_at":"2022-11-28T01:40:27.000000Z"}'];
final List<String> mockDialogsWithUpdatedStatusOnlyJson = ['{"id":180,"chat_type":{"id":1,"name":"Test dialog","description":"Dialog between two users","p2p":1,"secure":0,"readonly":0,"picture":"","sort":1},"user":{"id":20,"email":"andreypa@cashalot.co","last_access":"2023-07-17T03:54:39.000000Z","banned":false,"staff":{"id":11397,"firstname":"Ivan","lastname":"Ivanov","middlename":"Sergeevich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79084418489","email":"andreypa@cashalot.co","birthdate":"1976-02-29","avatar":null,"user_id":20}},"users":[{"id":20,"email":"andreypa@cashalot.co","last_access":"2023-07-17T03:54:39.000000Z","banned":false,"staff":{"id":11397,"firstname":"Ivan","lastname":"Ivanov","middlename":"Sergeevich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79084418489","email":"andreypa@cashalot.co","birthdate":"1976-02-29","avatar":null,"user_id":20}},{"id":40,"email":"eskov@cashalot.co","last_access":"2023-07-17T03:55:45.000000Z","banned":false,"staff":{"id":11464,"firstname":"Dmitriy","lastname":"Ivanov","middlename":"Dmitrievich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79140774664","email":"eskov@cashalot.co","birthdate":"1992-03-18","avatar":null,"user_id":40}}],"chat_users":[{"chat_id":180,"user_id":20,"chat_user_role_id":1,"active":true,"user":{"id":20,"email":"andreypa@cashalot.co","last_access":"2023-07-17T03:54:39.000000Z","banned":false,"staff":{"id":11397,"firstname":"Ivan","lastname":"Ivanov","middlename":"Sergeevich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79084418489","email":"andreypa@cashalot.co","birthdate":"1976-02-29","avatar":null,"user_id":20}}},{"chat_id":180,"user_id":40,"chat_user_role_id":2,"active":true,"user":{"id":40,"email":"eskov@cashalot.co","last_access":"2023-07-17T03:55:45.000000Z","banned":false,"staff":{"id":11464,"firstname":"Dmitriy","lastname":"Ivanov","middlename":"Dmitrievich","company":"Cashalot","dept":"Web department","position":"Developer","phone":"79140774664","email":"eskov@cashalot.co","birthdate":"1992-03-18","avatar":null,"user_id":40}}}],"name":"Dialog between two users","description":"Not specified","is_closed":0,"is_public":0,"picture":"","message":{"id":2207,"chat_id":180,"user_id":40,"parent_id":null,"message":"44","parent":null,"file":null,"statuses":[{"id":4805,"chat_id":180,"user_id":20,"chat_message_id":2207,"chat_message_status_id":3,"created_at":"2023-07-13T00:57:22.000000Z","updated_at":"2023-07-13T00:58:50.000000Z"},{"id":4806,"chat_id":180,"user_id":40,"chat_message_id":2207,"chat_message_status_id":4,"created_at":"2023-07-13T00:57:23.000000Z","updated_at":"2023-07-13T00:57:24.000000Z"}, {"id": 4802,"chat_id": 180,"user_id": 40,"chat_message_id": 2206,"chat_message_status_id": 4,"created_at": "2023-07-13T00:22:52.000000Z","updated_at": "2023-07-13T00:22:53.000000Z"}],"created_at":"2023-07-13T00:57:22.000000Z","updated_at":"2023-07-13T00:57:22.000000Z"},"message_count":220,"created_at":"2022-11-28T01:40:27.000000Z","updated_at":"2022-11-28T01:40:27.000000Z"}'];