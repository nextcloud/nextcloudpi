<?php

class L10N {
    private $translations = [];
    const defaultLanguage = "en_US";
    private $language;

    /**
     * @throws Exception
     **/
    public function __construct($desiredLanguages, $l10nDir)
    {
        if(!isset($desiredLanguages)) {
            $desiredLanguages = [];
        }

        $l10nDir = trim($l10nDir, '/');
        $availableLanguages = array_filter(scandir($l10nDir),
            function($s) use ($l10nDir) { return is_file($l10nDir."/".$s); });
        $availableLanguages = array_map(
                function($s) { return pathinfo($s)['basename']; },
                $availableLanguages);
        $lang = $this->find_language($availableLanguages, $desiredLanguages);
        $full_path = join('/', [$l10nDir, trim($lang, '/') . ".json"]);
        $this->language = $lang;
        if( !file_exists($full_path) || !$this->load($full_path) ) {
            $this->language = L10N::defaultLanguage;
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

    function find_language(array $availableLanguages, $desiredLanguage) {

        $availableLanguages = array_flip($availableLanguages);

        $langs = [];
        preg_match_all('~([\w-]+)(?:[^,\d]+([\d.]+))?~', strtolower($desiredLanguage), $matches, PREG_SET_ORDER);
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
            return L10N::defaultLanguage;
        }
        return $langs[0];
    }
}
