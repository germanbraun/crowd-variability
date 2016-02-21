# interfaz.coffee --
# Copyright (C) 2016 Giménez, Christian

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


# {Diagrama} = require './diagrama'
# {Class} = require './mymodel'

# Un poco de aliasing para acortar el código.
uml = joint.shapes.uml;

# ---------------------------------------------------------------------- 

graph = new joint.dia.Graph
diag = new Diagrama(graph)

paper = new joint.dia.Paper(
        el: $('#container')
        width: 1000
        height: 1000
        model: graph
        gridSize: 1
)

# Events for the Paper

# A Cell was clicked: select it.
paper.on("cell:pointerclick",
    (cellView, evt, x, y) ->
        if (cellView.highlighted == undefined or cellView.highlighted == false) 
            cellView.highlight()
            cellView.highlighted = true
        else
            cellView.unhighlight()
            cellView.highlighted = false
)

editclass = null

paper.on("cell:pointerdblclick",
    (cellView, evt, x, y) ->
        editclass = new EditClassView({el: $("#editclass")})
        editclass.set_classid(cellView.model.id)

)

css_clase = 
        '.uml-class-name-rect' : 
            fill: "#fff"
        '.uml-class-attrs-rect' : 
        	fill: "#fff"
        '.uml-class-methods-rect' : 
        	fill: "#fff"
        
# Interfaz

##
# CrearClaseView proporciona los elementos y eventos necesarios
#   para mostra una interfaz para crear una clase.
CrearClaseView = Backbone.View.extend(    
        initialize: () ->
        	this.render()
    
        render: () ->
            template = _.template( $("#template_crearclase").html(), {} )
            this.$el.html(template)

        events: 
        	"click a#crearclase_button" : "crear_clase"

        crear_clase: (event) ->
            alert("Creando: " + $("#crearclase_input").val() + "...")
            nueva = new Class($("#crearclase_input").val(), [], [])
            diag.agregar_clase(nueva)
);

EditClassView = Backbone.View.extend(
    initialize: () ->
        this.render()

    render: () ->
        template = _.template( $("#template_editclass").html())
        this.$el.html(template({classid: @classid}))

    events:
        "click a#editclass_button" : "edit_class"

    # Set this class ID and position the form onto the
    # 
    # Class diagram.
    set_classid : (@classid) ->
        modelpos = graph.getCell(@classid).position()
        containerpos = $("#container").position()

        this.$el.css(
            top: modelpos.x + containerpos.top,
            left: modelpos.y + containerpos.left,
            position: 'absolute',
            'z-index': 1
            )
        this.$el.show()

    get_classid : () ->
        return @classid
    
    edit_class: (event) ->
        # Set the model name
        cell = graph.getCell(@classid)
        cell.set("name", $("#editclass_input").val())
        
        # Update the view
        v = cell.findView(paper)
        v.update()

        # Hide the form.
        this.$el.hide()
)

# Instancia de CrearClaseView.
# 
crearclase = new CrearClaseView({el: $("#crearclase")});

exports = exports ? this

exports.graph = graph
exports.diag = diag
exports.paper = paper
exports.CrearClaseView = CrearClaseView
exports.EditClassView = EditClassView
exports.editclass = editclass
