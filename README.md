Provide a README.md file with your project that describes any details of your project that you think the grader will need to understand how it works and how to use it. You can also use this file to talk about any design choices or trade-offs you made. At a minimum, the README.md file should mention the following information:


The version of Ruby you used to run this application.
The browser (including version number) that you used to test this application.
The version of PostgreSQL you used to create any databases.
How to install, configure, and run the application.
Any additional details the grader may need to run your code.

Keep in mind that your grader may be unfamiliar with the problem domain. If you think that's a possibility, you may wish to add a brief discussion of the vocabulary and concepts used in the application.






# Search feaature not required for the assignment
#   # Refactor this later
#   def display_search(query)
#     # If redirected to "/" route, query would be nil
#     # This will set it to an empty string instead
#     query ||= ""
    
#     filtered = @entries.filter_map do |phrase_hash|
#       phrase = phrase_hash[:phrase]
#       context = phrase_hash[:context]
#       response = phrase_hash[:response]

#       next unless phrase.match?(/#{query}/i) || response.match?(/#{query}/i)

#       "<ol>" + phrase + 
#         # "<li>context: " + context + "</li>" +
#         "<li>response: " + response + "</li>" +
#       "</ol>" 
#     end.join("<br>")
#     # Have to refactor that to replace regardless of case
#     filtered.gsub(query, "<span style='color: red'>#{query}</span>")
#   end

# # HTML for search
# <hr style="width:100%", size="3", color=black>  
# <form action="/search" method="get">
#   <h2>Enter a phrase for which you would like an appropriate response</h2>
#   <input name="query"><br><br>
#   <button type="submit">Search</button>
# </form>

# <% unless display_search(@query) == "" %>
#   <p>Search results:</p>
#   <%=  display_search(@query) %>
# <% end %>
# <br><br>


<!-- get "/search" do
  @query = params[:query]
  erb :homepage
end -->