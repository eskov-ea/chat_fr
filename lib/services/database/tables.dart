final Map<String, String> tables = {
  'dialog' :
  'CREATE TABLE dialog ('
      'id INTEGER PRIMARY KEY, '
      'name varchar(255) DEFAULT NULL, '
      'description varchar(255) DEFAULT NULL, '
      'chat_type varchar(100) REFERENCES chat_type(name), '
      'user_id INTEGER REFERENCES user(id), '
      'message INTEGER REFERENCES message(id), '
      'is_closed TINYINT(1) DEFAULT 0, '
      'is_public TINYINT(1) DEFAULT 0, '
      'message_count INTEGER, '
      'picture text, '
      'created_at DATETIME DEFAULT CURRENT_TIMESTAMP, '
      'updated_at DATETIME DEFAULT CURRENT_TIMESTAMP );',

  'chat_type' :
  'CREATE TABLE chat_type ('
      'id INTEGER PRIMARY KEY, '
      'name varchar(255) DEFAULT NULL, '
      'description varchar(255) DEFAULT NULL, '
      'p2p TINYINT(1) DEFAULT NULL, '
      'secure TINYINT(1) DEFAULT NULL, '
      'readonly TINYINT(1) DEFAULT NULL, '
      'picture text );',


  'chat_user' :
  'CREATE TABLE chat_user ('
      'chat_id INTEGER, '
      'chat_user_role_id TINYINT(1), '
      'active BOOLEAN, '
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
      'secure TINYINT(1) DEFAULT NULL, '
      'last_access DATETIME DEFAULT NUll );',


  'message' :
  'CREATE TABLE message ('
      'id INTEGER PRIMARY KEY, '
      'chat_id INTEGER, '
      'user_id INTEGER, '
      'parent_id INTEGER, '
      'message text DEFAULT "", '
      'file INTEGER DEFAULT NULL REFERENCES file(id), '
      'created_at DATETIME DEFAULT CURRENT_TIMESTAMP, '
      'updated_at DATETIME DEFAULT CURRENT_TIMESTAMP );',


  'message_status' :
  'CREATE TABLE message_status ('
      'id INTEGER PRIMARY KEY, '
      'chat_id INTEGER, '
      'user_id INTEGER, '
      'chat_message_id INTEGER, '
      'chat_message_status_id INTEGER, '
      'created_at DATETIME DEFAULT CURRENT_TIMESTAMP, '
      'updated_at DATETIME DEFAULT CURRENT_TIMESTAMP );',


};