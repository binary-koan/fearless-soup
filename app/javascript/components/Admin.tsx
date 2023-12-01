import simpleRestProvider from "ra-data-simple-rest"
import {
  Admin,
  Datagrid,
  List,
  Resource,
  Show,
  SimpleShowLayout,
  TextField,
  fetchUtils
} from "react-admin"

const QuestionList = () => {
  return (
    <List>
      <Datagrid rowClick="show">
        <TextField source="id" />
        <TextField source="question" />
        <TextField source="ask_count" />
      </Datagrid>
    </List>
  )
}

const QuestionShow = () => {
  return (
    <Show>
      <SimpleShowLayout>
        <TextField source="id" />
        <TextField source="question" />
        <TextField source="answer" />
        <TextField source="context" />
        <TextField source="ask_count" />
      </SimpleShowLayout>
    </Show>
  )
}

const httpClient: typeof fetchUtils.fetchJson = (url, options = {}) => {
  if (!options.headers || !(options.headers instanceof Headers)) {
    options.headers = new Headers({ Accept: "application/json" })
  }
  options.headers.set(
    "X-CSRF-Token",
    document.querySelector("meta[name=csrf-token]")!.getAttribute("content") || ""
  )
  return fetchUtils.fetchJson(url, options)
}

const AdminApp = () => (
  <div style={{ position: "absolute", left: 0, width: "100vw" }}>
    <Admin dataProvider={simpleRestProvider(`${location.origin}/admin`, httpClient)}>
      <Resource name="questions" list={QuestionList} show={QuestionShow} />
    </Admin>
  </div>
)

export default AdminApp
