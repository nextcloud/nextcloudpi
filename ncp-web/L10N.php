<?php

class L10N {
    private $translations = [];
    const default_language = "en_US";
    private $language;

    /**
     * @throws Exception
     **/
    public function __construct($desired_languages, $l10n_dir)
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
        $full_path = join('/', [$l10n_dir, $lang . ".json"]);
        $this->language = $lang;
        if ($lang === L10N::default_language || !file_exists($full_path) || !$this->load($full_path)) {
            $this->language = L10N::default_language;
        }
    }

    function load($translationFile)
    {
        $json = json_decode(file_get_contents($translationFile), true);
        if (!is_array($json)) {
            $jsonError = json_last_error();
            return false;
        }
        $this->translations = array_merge($this->translations, $json['translations']);
        return true;
    }

    public function __($text) {
        if( isset($this->translations[$text])) {
            return $this->translations[$text];
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
