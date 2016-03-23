<?php 
/* 

   Copyright 2016 Giménez, Christian
   
   Author: Giménez, Christian   

   buildertest.php
   
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

require_once("common.php");

// use function \load;
load("owllinkbuilder.php", "translator/builders/");

use Wicom\Translator\Builders\OWLlinkBuilder;

class OWLlinkBuilderTest extends PHPUnit_Framework_TestCase
{

    public function testTranslate(){
        $expected = "
       <Tell kb=\"http://localhost/kb1\">   
       <owl:SubClassOf>
       <owl:Class IRI=\"Persona\" />
       <owl:Class abbreviatedIRI=\"owl:Thing\" />
       </owl:SubClassOf>
       <owl:SubClassOf>
       <owl:Class IRI=\"Cellphone\" />
       <owl:Class abbreviatedIRI=\"owl:Thing\" />
       </owl:SubClassOf>
    <owl:SubClassOf>
	<owl:ObjectSomeValuesFrom>
	    <owl:ObjectProperty IRI=\"hasCellphone\" />
	    <owl:Class abbreviatedIRI=\"owl:Thing\" />
	</owl:ObjectSomeValuesFrom>
	<owl:Class IRI=\"Person\" />
    </owl:SubClassOf>
   
    <owl:SubClassOf>
	<owl:ObjectSomeValuesFrom>
	    <owl:ObjectInverseOf>
		<owl:ObjectProperty IRI=\"hasCellphone\" />
	    </owl:ObjectInverseOf>
	    <owl:Class abbreviatedIRI=\"owl:Thing\" />
	</owl:ObjectSomeValuesFrom>
	<owl:Class IRI=\"Cellphone\" />
    </owl:SubClassOf>

    <owl:SubClassOf>
	<owl:Class IRI=\"Person\" />
	<owl:ObjectMinCardinality cardinality=\"1\">
	    <owl:ObjectProperty IRI=\"hasCellphone\" />
	</owl:ObjectMinCardinality>
    </owl:SubClassOf>

    <owl:SubClassOf>
	<owl:Class IRI=\"Persona\" />
	    <owl:ObjectMinCardinality cardinality=\"1\">
	    <owl:ObjectProperty IRI=\"hasCellphone\" />
	    </owl:ObjectMinCardinality>
    </owl:SubClassOf>

    <owl:SubClassOf>
	<owl:Class IRI=\"Cellphone\" />
	<owl:ObjectIntersectionOf>
	    <owl:ObjectMinCardinality cardinality=\"1\">
		<owl:ObjectInverseOf>
		    <owl:ObjectProperty IRI=\"hasCellphone\" />
		</owl:ObjectInverseOf>
	    </owl:ObjectMinCardinality>
	    <owl:ObjectMaxCardinality cardinality=\"1\">
		<owl:ObjectInverseOf>
		    <owl:ObjectProperty IRI=\"hasCellphone\" />
		</owl:ObjectInverseOf>
	    </owl:ObjectMaxCardinality>
	</owl:ObjectIntersectionOf>
    </owl:SubClassOf>
       </Tell>";
        
        $builder = new OWLlinkBuilder();

        $builder->translate_DL([
            ["subclass" => [
                ["class" => "Persona"],
                ["class" => "owl:Thing"],
            ]],
            ["subclass" => [
                ["class" => "Cellphone"],
                ["class" => "owl:Thing"]]],
            ["subclass" => [
                ["exists" => ["role" => "hasCellphone"]],
                ["class" => "Person"]]],
            ["subclass" => [
                ["exists" => ["inverse" =>
                              ["role" => "hasCellphone"]]],
                ["class" => "Cellphone"]]],
            ["subclass" => [
                ["class" => "Person"],
                ["mincard" =>
                 [1,
                  ["role" => "hasCellphone"]]]]],
            ["subclass" => [
                ["class" => "Cellphone"],
                ["intersection" => [
                    ["mincard" =>
                     [1,
                      ["inverse" => ["role" => "hasCellphone"]]]],
                    ["maxcard" =>
                     [1,
                      ["inverse" => ["role" => "hasCellphone"]]]]
                    ]]]]
        ]);
        
        $actual = $builder->get_product();
        $actual = $actual->to_string();

        $expected = process_xmlspaces($expected);
        $actual = process_xmlspaces($actual);
        $this->assertEqualXMLStructure($expected, $actual, true);
    }

}

?>
