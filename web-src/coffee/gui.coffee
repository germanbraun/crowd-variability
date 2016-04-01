# gui.coffee --
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


class GUI
    constructor: (@graph, @paper) ->
        @urlprefix = ""
        @diag = new Diagrama(@graph)
        @state = gui.State.selectionstate()
        @crearclase = new CrearClaseView({el: $("#crearclase")});
        @editclass = new EditClassView({el: $("#editclass")})
        @classoptions = new ClassOptionsView({el: $("#classoptions")})
        @relationoptions = new RelationOptionsView({el: $("#relationoptions")})
        @trafficlight = new TrafficLightsView({el:
            $("#trafficlight")})
        @owllinkinsert = new OWLlinkInsertView({el: $("#owllink_placer")})
        @errorwidget = new ErrorWidgetView({el: $("#errorwidget_placer")})
        gui.set_current_instance(this);

    set_urlprefix : (str) ->
        @urlprefix = str

    ##
    # What to do when the user clicked on a cellView.
    on_cell_clicked: (cellview, event, x, y) ->
        @state.on_cell_clicked(cellview, event, x, y, this)

    ##
    # Set the class Id of the class options GUI.
    set_options_classid: (model_id) ->
        @relationoptions.set_classid(model_id)
        @classoptions.set_classid(model_id)

    ##
    # Hide the class options GUI.
    hide_options: () ->
        @classoptions.hide()
        @relationoptions.hide()
        @editclass.hide()

    set_editclass_classid: (model_id) ->
        # editclass = new EditClassView({el: $("#editclass")})
        @editclass.set_classid(model_id)        

    ##
    # Add a class to the diagram.
    #
    # Params.:
    #  class_inst = A Class instance.
    add_class: (class_inst) ->
        @diag.agregar_clase(class_inst)

    ##
    # Delete a class from the diagram.
    #
    # Params.:
    # class_id a String with the class Id.
    delete_class: (class_id) ->
        @diag.delete_class_by_classid(class_id)

    edit_class: (class_id) ->
        # Set the model name
        cell = @graph.getCell(class_id)
        cell.set("name", $("#editclass_input").val())
        
        # Update the view
        v = cell.findView(paper)
        v.update()

    ##
    # Report an error to the user.
    #
    # Params.:
    # status : String, the status text.
    # error : String, error message
    show_error: (status, error) ->
        $.mobile.loading("hide")
        @errorwidget.show(status, error)

    ##
    # Send to the server a translation Request.
    request_translation: (format, callback_function) ->
        json = this.diag_to_json()
        url = @urlprefix + "translator/calvanesse.php"
        console.log("Requesting at " + url)
        $.ajax(
            type: "POST",
            url: url,
            data:            
                "format":
                    format
                "json":
                    json
            success:
                callback_function
            error:
                gui.show_error
        )
    ##
    # Send to the server a "is satisfiable" request
    request_satisfiable: (callback_function) ->
        postdata = "json=" + this.diag_to_json()
        url = @urlprefix + "querying/satisfiable.php"
        console.log("Requesting at " + url)
        $.ajax(
            type: "POST",
            url: url,
            data: postdata,
            success: callback_function,
            error: gui.show_error
            )
        
    ##
    # Put the traffic light on green.
    traffic_light_green: () ->
        @trafficlight.turn_green()

    ##
    # Put the traffic light on red.
    traffic_light_red: () ->
        @trafficlight.turn_red()

    ##
    # Update the interface with satisfiable information.
    #
    # Params.:
    # data is a JSON string with the server response.
    update_satisfiable: (data) ->
        console.log(data)
        obj = JSON.parse(data);
        if obj.satisfiable.kb
            @trafficlight.turn_green()
        else
            @trafficlight.turn_red()
        $("#reasoner_input").html(obj.reasoner.input)
        $("#reasoner_output").html(obj.reasoner.output)
        $.mobile.loading("hide")
        this.change_to_details_page()
        

    ##
    # Send a POST to the server for checking if the diagram is
    # satisfiable.
    check_satisfiable: () ->
        $.mobile.loading("show", 
            text: "Consulting server...",
            textVisible: true,
            textonly: false
        )
        this.request_satisfiable(
            gui.update_satisfiable # Be careful with the context
            # change! this will have another object...
            )


    update_translation: (data) ->
        format = @crearclase.get_translation_format()
        if format == "html" 
            $("#html-output").html(data)
            $("#html-output").show()
            $("#owllink_source").hide()
        else
            $("#owllink_source").text(data)
            $("#owllink_source").show()
            $("#html-output").hide()
        
        # Goto the Translation text
        $.mobile.loading("hide")
        this.change_to_details_page()
        
        console.log(data)

    ##
    # Event handler for translate diagram to OWLlink using Ajax
    # and the translator/calvanesse.php translator URL.
    translate_owllink: () ->
        format = @crearclase.get_translation_format()
        $.mobile.loading("show", 
            text: "Consulting server...",
            textVisible: true,
            textonly: false
        )
        this.request_translation(format, gui.update_translation)


    change_to_details_page: () ->
        $.mobile.changePage("#details-page",
            transition: "slide")
    change_to_diagram_page: () ->
        $.mobile.changePage("#diagram-page",
            transition: "slide",
            reverse: true)

    ##
    # Show the "Insert OWLlink" section.
    show_insert_owllink: () ->
        this.change_to_details_page()

    ##
    # Set the OWLlink addon at the "Insert OWLlink" section.
    set_insert_owllink: (str) ->
        @owllinkinsert.set_owllink(str)

    diag_to_json: () ->
        json = @diag.to_json()
        json.owllink = @owllinkinsert.get_owllink()
        return JSON.stringify(json)
        
        


exports = exports ? this

if exports.gui == undefined
    exports.gui = {}


exports.gui.set_current_instance = (gui_instance) ->
    exports.gui.gui_instance = gui_instance

##
# This is sooo bad, but the context of a $.post callback function
# differs from the source caller class.
#
# We need to set a global guiinst variable with one GUI.gui instance.
exports.gui.update_satisfiable = (data) ->
    exports.gui.gui_instance.update_satisfiable(data)

exports.gui.update_translation = (data) ->
    exports.gui.gui_instance.update_translation(data)

exports.gui.show_error = (jqXHR, status, text) ->
    exports.gui.gui_instance.show_error(status + ": " + text , jqXHR.responseText)

exports.gui.GUI = GUI
