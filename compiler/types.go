package main

type Machine struct {
    Name        string                         `json:"name"`
    Alphabet    []string                       `json:"alphabet"`
    Blank       string                         `json:"blank"`
    States      []string                       `json:"states"`
    Initial     string                         `json:"initial"`
    Finals      []string                       `json:"finals"`
    Transitions map[string][]Transition        `json:"transitions"`
}

type Transition struct {
    Read    string `json:"read"`
    ToState string `json:"to_state"`
    Write   string `json:"write"`
    Action  string `json:"action"`
}
