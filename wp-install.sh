#!/bin/sh

sudo chown $USER_UID:$USER_GID -R /var/www/html

FLAG_FILE="/var/www/html/.wordpress_set"

if [ ! -f "$FLAG_FILE" ]; then
    echo "Setting WordPress for the first time..."

    wp core download --version=$WP_VERSION --locale=ja

    wp config create --dbname=$MYSQL_DATABASE --dbuser=$MYSQL_USER --dbpass=$MYSQL_PASSWORD --dbhost=db --path=/var/www/html

    # WordPressセットアップ admin_user,admin_passwordは管理画面のログインID,PW
    wp core install \
        --url="$WP_SITE_URL" \
        --title="$WP_SITE_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL"

    # タイムゾーンと日時表記
    wp option update timezone_string 'Asia/Tokyo'
    wp option update date_format 'Y-m-d'
    wp option update time_format 'H:i'

    # キャッチフレーズの設定 (空にする)
    wp option update blogdescription ''

    # デフォルトの投稿を削除
    wp plugin delete hello.php
    wp plugin delete akismet

    # パーマリンク更新
    wp option update permalink_structure /%category%/%post_id%/

    # プラグインのインストール (必要に応じてコメントアウトを外す)
    # wp plugin install wp-multibyte-patch --activate
    # wp plugin install show-current-template --activate
    wp plugin install wordpress-importer --activate
    wp plugin install wpvivid-backuprestore --activate
    wp plugin install debug-bar --activate
    wp plugin install query-monitor --activate
    wp plugin install theme-check --activate
    wp plugin install search-regex --activate
    wp plugin install rewrite-rules-inspector --activate
    wp plugin install duplicate-post --activate
    wp plugin install /tmp/advanced-custom-fields-pro.zip --activate
    # wp plugin install backwpup --activate
    # wp plugin install siteguard --activate
    # wp plugin install contact-form-7 --activate
    # wp plugin install wp-mail-smtp --activate
    # wp plugin install all-in-one-seo-pack --activate
    # wp plugin install broken-link-checker --activate
    # wp plugin install addquicktag --activate

    # プラグインアップデート
    wp plugin update advanced-custom-fields-pro

    # プラグインの日本語化
    wp language plugin install ja --all

    # テーマの削除
    wp theme delete twentytwentythree
    wp theme delete twentytwentytwo

    # ダミー投稿・固定ページ追加
    # wp import wordpress-theme-test-data.xml --authors=create
    # wp import /tmp/wordpress-theme-test-data-ja.xml --authors=create

    #Wpvivid設定変更
    current_setting=$(wp option get wpvivid_common_setting --format=json)

    new_setting=$(echo $current_setting | jq '.memory_limit = "1024M" | .max_execution_time = 3000 | .restore_max_execution_time = 3000 | .restore_memory_limit = "1024M"')

    wp option update wpvivid_common_setting "$new_setting" --format=json

        #ACF設定変更
    if [ -n "$WP_ACF_LICENSE_KEY" ]; then
        wp option update acf_pro_license "$WP_ACF_LICENSE_KEY"
    fi
    touch "$FLAG_FILE"
    echo "WordPress set and flag file created."
else
    echo "WordPress already set. Skipping..."
fi
