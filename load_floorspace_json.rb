require 'openstudio'

#OpenStudio::Logger::instance.standardOutLogger.setLogLevel(OpenStudio::Debug)

puts "Loading #{ARGV[0]}"

contents = nil
File.open(ARGV[0], 'r') do |file|
  contents = file.read
end

model = OpenStudio::Model::Model.new

floorplan = OpenStudio::FloorplanJS::load(contents).get

ft = OpenStudio::Model::FloorplanJSForwardTranslator.new

remove_missing_objects = true
floorplan = ft.updateFloorplanJS(floorplan, model, remove_missing_objects)

rt = OpenStudio::Model::ThreeJSReverseTranslator.new

osm_format = true
scene = floorplan.toThreeScene(osm_format)

export_model = rt.modelFromThreeJS(scene).get

mm = OpenStudio::Model::ModelMerger.new
export_model_handle_mapping = mm.suggestHandleMapping(model, export_model)

mm.mergeModels(model, export_model, export_model_handle_mapping)

model.save('model.osm', true)

ft = OpenStudio::Model::ThreeJSForwardTranslator.new
triangulate = true
scene = ft.modelToThreeJS(model, triangulate)
pretty_print = false
json = scene.toJSON(pretty_print)

File.open('model.json', 'w') do |file|
  file.puts json
end

puts 'Goodbye'