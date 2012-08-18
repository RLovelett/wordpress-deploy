<?php
/**
 * The base configurations of the WordPress.
 *
 * This file has the following configurations: MySQL settings, Table Prefix,
 * Secret Keys, WordPress Language, and ABSPATH. You can find more information
 * by visiting {@link http://codex.wordpress.org/Editing_wp-config.php Editing
 * wp-config.php} Codex page. You can get the MySQL settings from your web host.
 *
 * This file is used by the wp-config.php creation script during the
 * installation. You don't have to use the web site, you can just copy this file
 * to "wp-config.php" and fill in the values.
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'production_database_name');

/** MySQL database username */
define('DB_USER', 'some_user');

/** MySQL database password */
define('DB_PASSWORD', 'trecuwawraJaZe6P@kucraDrachustUq');

/** MySQL hostname */
define('DB_HOST', 'abbott.biz:6654');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', 'ryan-collate');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         '<r-*;SgTbz7&}VlyE.[H,F~4GB+s>)MRm9Y8KuUw{c15!Q3i/vIqtA^|jOPa6feW');
define('SECURE_AUTH_KEY',  'a%*bxGH)us+mQOPh7[I2$U{;Eijk.r#w!T>NZz&S?<V:AWY~vyC]3odLe}q9D56t');
define('LOGGED_IN_KEY',    'k#>.*)5W,V|OJSHRF?;dvmb/{LGg8hNB2ZQK]s$0+-1Itw7ux^YElr@9fn6i<P4j');
define('NONCE_KEY',        'hCOW{xmyPG*z;oYJtgRvMFrnI.k0%&1KL,ewUT^2!>up=E:QD/)+d[|6$#?qSs]<');
define('AUTH_SALT',        '~qC3]YB&ou/ry6<z{-WhPNR|I.mL2)XdHS+1p}?Ql^MKEiGA(>:f=#tc%;84Tkx7');
define('SECURE_AUTH_SALT', 'RF,ZU<H^$Cgq}8S&[Y4zE65OBW(+.:0LDMGlr/ujk#JT{-?;29iyP*d~)nVp1cbe');
define('LOGGED_IN_SALT',   'aT6q#EXyj3s*=Qf%0doLFc$?@O4i:S)I[GZRH/PWJw{^mY8(N,.xpMVD91etnv}&');
define('NONCE_SALT',       'FSOjHgapy-3b>&B^c@Pzw49ALqZ!<M7uvGJUnV;t#.C/kxoX:5*}{21=hsRT?l8,');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each a unique
 * prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'ryan_';

/**
 * WordPress Localized Language, defaults to English.
 *
 * Change this to localize WordPress. A corresponding MO file for the chosen
 * language must be installed to wp-content/languages. For example, install
 * de_DE.mo to wp-content/languages and set WPLANG to 'de_DE' to enable German
 * language support.
 */
define('WPLANG', 'de_DE');

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 */
define('WP_DEBUG', true);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
