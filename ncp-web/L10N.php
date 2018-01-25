<?php

class L10N {
    private $translations = [];
    const default_language = "en_US";
    private $language;

    public function __construct($desired_languages, $l10n_dir, $modules_path=null)
    {
        if (!isset($desired_languages)) {
            $desired_languages = "";
        }

        $l10n_dir = trim($l10n_dir, '/');
        $available_languages = array_filter(scandir($l10n_dir),
            function ($s) {
                return pathinfo($s, PATHINFO_EXTENSION) == "json";
            });
        $available_languages = array_map(
            function ($s) {
                return basename($s, ".json");
            },
            $available_languages);
        $lang = $this->find_language($available_languages, $desired_languages);
        $this->language = $lang;
        if ($lang === L10N::default_language || !file_exists(join('/', [$l10n_dir, $lang . ".json"])) || !$this->load($lang, $l10n_dir, $modules_path)) {
            $this->language = L10N::default_language;
        }
    }

    function load($lang, $l10n_dir, $modules_path)
    {
      $modules_path = join('/', [trim($modules_path, '/'), "l10n"]);
      $files = [join('/', [$l10n_dir, $lang . ".json"])];
      if (is_dir($modules_path)) {
        foreach (scandir($modules_path) as $dir) {
          $file_path = join('/', [$modules_path, trim($dir, '/'), $lang . ".json"]);
          if (is_file($file_path)) {
            array_push($files, $file_path);
          }
        }
      }

      $jsonError = null;
      foreach ($files as $file) {
        $module_name = pathinfo($file, PATHINFO_DIRNAME);
        if( $module_name == pathinfo($l10n_dir, PATHINFO_BASENAME)) {
          $module_name = "__core__";
        }
        $json = json_decode(file_get_contents($file), true);
        if (!is_array($json)) {
          $jsonError = json_last_error();
          continue;
        }
        $this->translations[$module_name] = $json['translations'];
      }
      return ($jsonError == null);
    }

    public function __($text, $module="__core__") {
        if( isset($this->translations[$module]) && isset($this->translations[$module][$text])) {
            return $this->translations[$module][$text];
        }
        return $text;
    }

    function find_language(array $available_languages, $desired_language) {

        $available_languages = array_flip($available_languages);

        $langs = [];
        preg_match_all('~([\w-]+)(?:[^,\d]+([\d.]+))?~', strtolower($desired_language), $matches, PREG_SET_ORDER);
        foreach($matches as $match) {

            list($a, $b) = explode('-', $match[1]) + array('', '');
            $value = isset($match[2]) ? (float) $match[2] : 1.0;

            if(isset($available_languages[$match[1]])) {
                $langs[$match[1]] = $value;
                continue;
            }

            if(isset($available_languages[$a])) {
                $langs[$a] = $value - 0.1;
            }

        }
        arsort($langs);

        if(count($langs) == 0) {
            return L10N::default_language;
        }
        return array_keys($langs)[0];
    }
}
