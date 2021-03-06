package ci

import (
	"tool/file"
	"tool/http"
	"tool/exec"
	"encoding/yaml"
)

command: genworkflows: task: {
	for w in workflows {
		"\(w.file)": file.Create & {
			filename: w.file
			contents: """
				# Generated by internal/ci/ci_tool.cue; do not edit

				\(yaml.Marshal(w.schema))
				"""
		}
	}
}

// vendorgithubschema is expected to be run within the cuelang.org/go
// cue.mod directory
command: vendorgithubschema: {
	get: http.Get & {
		request: body: ""
		url: "https://raw.githubusercontent.com/SchemaStore/schemastore/f7a0789ccb3bd74a720ddbd6691d60fd9e2d8b7a/src/schemas/json/github-workflow.json"
	}
	convert: exec.Run & {
		stdin: get.response.body
		cmd:   "go run cuelang.org/go/cmd/cue import -f -p json -l #Workflow: jsonschema: - --outfile pkg/github.com/SchemaStore/schemastore/src/schemas/json/github-workflow.cue"
	}
}
