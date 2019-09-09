# ncl-formats

ncl-formats is a pure-lua tool for (1) template processing and (2) file convert NCL documents.
More precisily, it can handle the following formats:

* web templates languages
  * [Jinja2](http://jinja.pocoo.org)  
  ```bash
  $ lua ncl-formats.lua padding.json jinja2 template.j2 
  ```

  * [Mustache](https://mustache.github.io/)  
  ```bash
  $ lua ncl-formats.lua padding.json mustache template.mustache partial1.mustache partial2.mustache ...
  ```

* NCL templates languages
  * [TAL](https://github.com/TeleMidia/tal-processor)    
  TODO. 
  
  * [XTemplate](https://github.com/joeldossantos/aXT)  
  TODO. 
  
  * [Luar](https://code.google.com/archive/p/luar-template-engine/)  
  TODO.
  
  * [LuaTPL](https://github.com/robertogerson/luatpl)  
  TODO.
  
* NCL-like languages
  * [RAW NCL](https://github.com/TeleMidia/dietncl)  
    TODO.
  
  * [sNCL](https://github.com/lucastercas/sncl)  
  TODO.
  
  * [NCL-ltab](http://www.telemidia.puc-rio.br/files/biblio/2018_09_dodsworth.pdf)  
  TODO.
  
  * [JNCL](http://www.midiacom.uff.br/~caleb/jns/)  
  TODO.
  
  
  ## Instalation
  
  
  ```bash
  $ luarocks install ncl-formats
  ```
