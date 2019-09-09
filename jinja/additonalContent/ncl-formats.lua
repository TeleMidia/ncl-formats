#!/usr/local/bin/lua

--- @module ncl_generator
-- Generates ncl final document based on template and using padding document.
-- It uses Lupa a pure Lua implementation for Jinja2 engine and Lustache to 
-- process Mustache documents.
-- To work properly, Lupa need LuLPeg module(a pure Lua Lpeg implementation).
-- LuLPeg does not need to be imported, but it should be kept in dependences 
-- folder to be found by Lupa. 
-- Lustache main module should be kept in dependences folder 
-- whilst it dependences must be in lustache subfoder

package.path = package.path .. ';dependences/?.lua'
local json = require ("json")

-- only necessary for a more beautiful output in debug mode
local pprint = require ("pprint")

local lupa = ''
local lustache = ''

local data = {}

function handler(evt)
    if  evt.class == 'ncl' and evt.type == 'attribution' and evt.action == 'start' then
        local i = 0 
        if evt.name == 'template' then
            data.template = evt.value
            pprint("----Template document-------")
            pprint(data.template)
        elseif evt.name == 'padding' then 
            data.padding = evt.value
            pprint("----Padding document-------")
            pprint(data.padding)
        elseif evt.name == 'jinja2' then
            data.engine = evt.value
            pprint("----Jinja2 Template Engine selected-------")
            pprint(data.engine)
        end
    end
end

-- event.register(handler)

--Following lines are just for testing, once Ginga implementation is not working properly
data.template = "additionalContent_child.ncl.j2"
data.padding = "padding.json"
data.engine = "jinja2"

pprint(data)

--- deserialize_json Deserialize padding document.templates..
-- It checks whether padding document is in correct extension and raise an error otherwise.
-- @param name padding document to deserialized
-- @return deserialize data
local function deserialize_json(name)

    local extension = name:match("^.+(%..+)$")
    local fileHandler = ''
    local content = ''
    local desData = ''
    if DEBUG then pprint(string.format("Padding extension: %s", extension)) end
    if extension ~= ".json" then
        error("Padding document in wrong format!!!") 
    else
        fileHandler = assert(io.open(name, "r"))
        content = fileHandler:read("*all")
        desData = json:decode(content) 
        fileHandler:close()
    end
    return desData
end

--- mysplit split name using sep as separator.
-- @param imputstr string.
-- @param sep delimeter string.
-- @return table containing substrings on inputstr.
function mysplit(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

--- handle_name Generate final ncl-document name.
--  @param template_doc name of template families.
--  @return name based on template_doc
local function handle_name(template_doc)
    name_table = mysplit(template_doc, '.')-- pprint(evt)
    if string.gmatch(name_table[1], 'child') then
        name_table = mysplit(name_table[1], '_')
    end
    if string.gmatch(name_table[1], 'base') then
        name_table = mysplit(name_table[1], '_') 
    end
    return name_table[1]
end

--- handle_template handle mustache templates using sep as separator.
-- @param template_doc string.
-- @return string with information ftom the opened template.
local function handle_template(template_doc)
    local extension = template_doc:match("^.+(%..+)$")
    local fileHandler = nil
    if DEBUG then pprint(string.format("Template extension of %s: %s", template_doc, extension)) end
    if extension ~= ".mustache" then
        error("Template document in wrong format!!!") 
    else
        fileHandler = assert(io.open("templates/" .. template_doc, "r"))
        content = fileHandler:read("*all")
        fileHandler:close()
    end
    return content
end

-- @param template_doc string.
-- @return string with information ftom the opened template.
local function handle_template(template_doc)
    local extension = template_doc:match("^.+(%..+)$")
    local fileHandler = nil
    if DEBUG then pprint(string.format("Template extension of %s: %s", template_doc, extension)) end
    if extension ~= ".mustache" then
        error("Template document in wrong format!!!") 
    else
        fileHandler = assert(io.open("templates/" .. template_doc, "r"))
        content = fileHandler:read("*all")
        fileHandler:close()
    end
    return content
end

--- process_template handles templating processing using Lupa pure Lua Jinja implementation.
-- Enable debud mode whether "-d" is passed as arguments.
-- @param 
-- @return 
local function process_jinja2(data, debug)


    DEBUG = debug or true

    local padding_doc = data.padding
    local template_doc = data.template
    local engine = data.engine

    if DEBUG then
        log_initial = string.format("Starting generating ncl document from %s with %s on %s template engine",
                                    template_doc, padding_doc, engine )
        pprint(log_initial)
    end

    local context = deserialize_json(padding_doc)

    if DEBUG then
        pprint(context)
    end
    
    local env = lupa.configure{
                loader=lupa.loaders.filesystem('./templates'),
                trim_blocks=true,
                lstrip_blocks=true
    }
    content = {files_list = context}
    ncl = lupa.expand_file(template_doc, content)

    ncl_filename = handle_name(template_doc)
    if DEBUG then
        pprint(string.format("filename: %s", ncl_filename))
    end
    ncl_doc = assert(io.open(ncl_filename .. '.ncl', "w"))
    ncl_doc:write(ncl)
    ncl_doc:close()
end

local function process_mustache(data, debug)

    DEBUG = debug or true

    local padding_doc = data.padding
    local template_doc = data.template
    local engine = data.engine

    if DEBUG then
        log_initial = string.format("Starting generating ncl document from %s with %s on %s template engine",
                                    template_doc, padding_doc, engine )
        pprint(log_initial)
    end

    local content = deserialize_json(padding_doc)

    local i = 0 
    local index = {}
    local next = {}
    for i=1, #content[1].contents do
        index[i] = i
        content[1].contents[i].index = index[i]
        if i ~= #content[1].contents then
            next[i] = i+1 
            content[1].contents[i].next = next[i]
        end
    end  

    context = content[1]

    if DEBUG then
        pprint(context)
    end

    -- Grab content from templates
    local i = 0
    local baseTemplateData = handle_template(template_doc)
    local templatesData = {}
    local partials = {}
    --name of the files must be same as the partials in the main template document,
    --otherwise logic will fail!!!!!!!!!!!!!
    for i = 1, #data.partial do
        templatesData[i] = handle_template(data.partial[i])
        local name = mysplit(data.partial[i], data.partial[i]:match(".mustache"))
        partials[name[1]] = templatesData[i]
    end
    if DEBUG then 
        pprint("Template Data")
        pprint(templatesData)
    end

    if DEBUG then
        pprint("Partials table:")
        pprint(partials)
    end

    output = lustache:render(baseTemplateData, context, partials)

    if DEBUG then
        pprint(output)
    end
    
    ncl_doc = mysplit(template_doc, template_doc:match(".mustache"))
    pprint(string.format("ncl_doc %s",ncl_doc[1]))
    fh = assert(io.open(ncl_doc[1], "w"))
    fh:write(output)
    fh:close()
end


if data.engine == 'jinja2' then
    lupa = require ("lupa")
    pprint("Load Jinja2 engine")
    process_jinja2(data)
elseif data.engine == 'mustache' then
    lustache = require ("lustache")
    pprint("Load Mustache engine")
    process_mustache(data)
else 
    pprint("Engine not recognized")
end

-- event.post('in', {
--     class  = 'ncl',
--     type   = 'presentation',
--     action = 'stop'
-- })

pprint("Finished Template Processing")