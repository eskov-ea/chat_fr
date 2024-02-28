final Map<String, String> tables = {
  'dialog' :
  'CREATE TABLE dialog ('
      'id INTEGER PRIMARY KEY, '
      'name varchar(255) DEFAULT NULL, '
      'description varchar(255) DEFAULT NULL, '
      'chat_type_name varchar(100) REFERENCES chat_type(name), '
      'author_id INTEGER NOT NULL, '
      'last_message_id INTEGER REFERENCES message(id), '
      'is_closed TINYINT(1) DEFAULT 0, '
      'is_public TINYINT(1) DEFAULT 0, '
      'message_count INTEGER, '
      'picture text, '
      'created_at DATETIME DEFAULT CURRENT_TIMESTAMP, '
      'updated_at DATETIME DEFAULT CURRENT_TIMESTAMP );',

  'chat_type' :
  'CREATE TABLE chat_type ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name varchar(255) DEFAULT NULL, '
      'description varchar(255) DEFAULT NULL, '
      'p2p TINYINT(1) DEFAULT NULL, '
      'secure TINYINT(1) DEFAULT NULL, '
      'readonly TINYINT(1) DEFAULT NULL, '
      'picture text );',


  'chat_user' :
  'CREATE TABLE chat_user ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'chat_id INTEGER, '
      'chat_user_role_id TINYINT(1), '
      'active TINYINT(1), '
      'user_id INTEGER(255) REFERENCES user(id) );',


  'user' :
  'CREATE TABLE user ('
      'id INTEGER PRIMARY KEY, '
      'firstname varchar(255) DEFAULT NULL, '
      'lastname varchar(255) DEFAULT NULL, '
      'middlename varchar(255) DEFAULT NULL, '
      'company varchar(255) DEFAULT NULL, '
      'dept varchar(255) DEFAULT NULL, '
      'position varchar(255) DEFAULT NULL, '
      'phone varchar(100) DEFAULT NULL, '
      'email varchar(100) DEFAULT NULL, '
      'birthdate DATE DEFAULT NULL, '
      'avatar text, '
      'banned TINYINT(1) DEFAULT 0, '
      'last_access DATETIME DEFAULT NUll );',


  'message' :
  'CREATE TABLE message ('
      'id INTEGER PRIMARY KEY, '
      'chat_id INTEGER NOT NULL, '
      'user_id INTEGER NOT NULL, '
      'parent_id INTEGER DEFAULT NULL, '
      'message text DEFAULT "", '
      'file INTEGER DEFAULT NULL, '
      'created_at DATETIME DEFAULT CURRENT_TIMESTAMP, '
      'updated_at DATETIME DEFAULT CURRENT_TIMESTAMP );',


  'message_status' :
  'CREATE TABLE message_status ('
      'id INTEGER PRIMARY KEY, '
      'chat_id INTEGER NOT NULL, '
      'user_id INTEGER NOT NULL, '
      'chat_message_id INTEGER NOT NULL REFERENCES message(id) ON DELETE CASCADE, '
      'chat_message_status_id INTEGER NOT NULL, '
      'created_at DATETIME DEFAULT CURRENT_TIMESTAMP, '
      'updated_at DATETIME DEFAULT CURRENT_TIMESTAMP );',


  'app_settings' :
  'CREATE TABLE app_settings ('
      'id INTEGER PRIMARY KEY, '
      'device_id varchar(255) DEFAULT NULL, '
      'first_initialize TINYINT(1) DEFAULT 1, '
      'created_at DATETIME DEFAULT CURRENT_TIMESTAMP );',
};