<?php 
/* 

   Copyright 2016 Giménez, Christian
   
   Author: Giménez, Christian   

   htmldocument.php
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Wicom\Translator\Documents;

use function \load;
load('document.php');

class HTMLDocument extends Document{
    protected $content = null;

    function __construct(){
        $this->content = "";
    }

    public function insert_class($name){
        $this->content .= "$name";
    }

    public function insert_subclassof($child_class, $father_class){
        // replace spaces
        $child_class = str_replace(" ", "_", $child_class);
        $father_class = str_replace(" ", "_", $father_class);
        $this->content .= "<p>$child_class &#8849; $father_class</p>";
    }

    public function end_document(){
    }
    
    public function to_string(){
        return $this->content;
    }
}
?>