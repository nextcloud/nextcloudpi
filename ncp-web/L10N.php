<?php

class L10N {
    private $translations = [];
    public const defaultLanguage = "en_us";
    private $language;

    /**
     * @throws Exception
     **/
    public function __construct($lang, $l10nDir)
    {
        $full_path = join('/', array(trim($l10nDir, '/'), trim($lang, '/') . ".json"));
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
}
