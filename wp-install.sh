#!/bin/bash

wp core download 

wp config create --dbname=myapp --dbuser=user --dbpass=userpassword --dbhost=db --path=/var/www/html

# WordPressセットアップ admin_user,admin_passwordは管理画面のログインID,PW
wp core install \
--url='http://localhost:80' \
--title='サイトのタイトル' \
--admin_user='wordpress' \
--admin_password='wordpress' \
--admin_email='info@test.com' \


# 日本語化
wp language core install ja --activate 

# タイムゾーンと日時表記
wp option update timezone_string 'Asia/Tokyo' 
wp option update date_format 'Y-m-d' 
wp option update time_format 'H:i' 

# キャッチフレーズの設定 (空にする)
wp option update blogdescription '' 

# プラグインの削除 (不要な初期プラグインを削除)
wp plugin delete hello.php 
wp plugin delete akismet 

# プラグインのインストール (必要に応じてコメントアウトを外す)
# wp plugin install wp-multibyte-patch --activate 
# wp plugin install show-current-template --activate 
# wp plugin install wordpress-importer --activate 
wp plugin install wpvivid-backuprestore --activate 
# wp plugin install backwpup --activate 
# wp plugin install siteguard --activate 
# wp plugin install contact-form-7 --activate 
# wp plugin install wp-mail-smtp --activate 
# wp plugin install all-in-one-seo-pack --activate 
# wp plugin install broken-link-checker --activate 
# wp plugin install addquicktag --activate 

# テーマの削除
wp theme delete twentytwentythree 
wp theme delete twentytwentytwo 

# ダミー投稿・固定ページ追加
# wp import wordpress-theme-test-data.xml --authors=create 
# wp import wordpress-theme-test-data-ja.xml --authors=create 

# デフォルトの投稿を削除
wp post delete 1 2 3 --force 

# パーマリンク更新
wp option update permalink_structure /%category%/%post_id%/ 