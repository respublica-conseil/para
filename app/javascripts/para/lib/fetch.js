import crossFetch from "cross-fetch";

export const GET = "GET";
export const POST = "POST";
export const PATCH = "PATCH";
export const DELETE = "DELETE";

// This method is a shortcut method for calling `fetch` with a setup that allows calling
// the Rails backend, preprocessing the response text or throwing an error if the response
// has a 400+ status code.
//
// This is useful to fetch a remote partial from the server or submit a sub-part of a form
// like used in the FormBranchConditionsEditorManager component.
//
export const fetch = (url, fetchOptions = {}) => {
  const csrfToken = document.querySelector("meta[name='csrf-token']").content;

  fetchOptions.headers = fetchOptions.headers || {};
  fetchOptions.headers["X-CSRF-Token"] = csrfToken;
  
  const options = {
    method: "GET",
    credentials: "include",
    ...fetchOptions
  };

  return crossFetch(url, options).then(
    // Handle the server response and potential form errors depending on the type of the
    // response status code
    response => {
      if (response.ok) {
        return response.text();
      } else {
        const error = new Error(response.statusText);
        error.response = response;
        throw error;
      }
    }
  );
};

