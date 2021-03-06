#' Creates a description file for a compendium
#'
#' The idea behind a compendium is to have a minimal description file that makes
#' it easy for anyone to 'install' your analysis dependencies. This makes it
#' possible for someone to run your code easily.
#'
#' To automatically populate author information, you may set usethis options in your `.rprofile` like so.
#' \code{options(
#'   usethis.full_name = "Karthik Ram",
#'   usethis.description = list(
#'   `Authors@R` = 'person("Karthik", "Ram", email = "karthik.ram@gmail.com", role = c("aut", "cre"),
#'   comment = c(ORCID = "0000-0002-0233-1757"))',
#'   License = "MIT + file LICENSE",
#'   Version = "0.0.0.9000"
#'   )
#' )}
#'
#' @param type Default here is compendium
#' @param package  Name of your compendium
#' @param description  Description of your compendium
#' @param version  Version of your compendium
#' @param path path to project (in case it is not in the current working directory)
#' @importFrom desc description
#'
#' @export
write_compendium_description <-
  function(type = "Compendium",
           package = "Compendium title",
           description = "Compendium description",
           version = "0.0.1",
           path = ".") {
    
    # browser()

    Depends <- get_dependencies(path)
    if(is.null(Depends))
        stop("No packages found in any script or notebook", call. = FALSE)
    remote_pkgs <- NULL
    
    remotes <- get_remotes(Depends)
    if(!is.null(remotes)) remote_pkgs <- unlist(strsplit(remotes, "/"))
    # if (length(remote_pkgs > 0))
    #  Depends <- Depends[-which(Depends %in% remote_pkgs)]
    # Commenting lines above because stuff in Remotes should also 
    # be in Depends.
    
    if (length(remote_pkgs > 0)) {
      fields <-
        list(
          Type = "Compendium",
          Package = package,
          Version = version,
          Description = description,
          Depends = paste0(
            Depends,
            collapse = ", "),
            Remotes = paste0(remotes, collapse = ", ")
          )
  
      
    } else {
      fields <-
        list(
          Type = "Compendium",
          Package = package,
          Version = version,
          Description = description,
          Depends = paste0(
            Depends,
            collapse = ", ")
        )
    }
    
    # TO-FIX-SOMEDAY
    # Using an internal function here
    # A silly hack from Yihui to stop the internal function use warning.
    # Not sure this is a good thing to do, but for now YOLO.
    # %:::% is in zzz.R
    
   #  tidy_desc <- "usethis" %:::% "tidy_desc"
   #build_desc <- "build_description"
    
    
    desc <- build_description_internal(fields)
    desc <- desc::description$new(text = desc)
    
    
    tidy_desc_internal(desc)
    lines <-
      desc$str(by_field = TRUE,
               normalize = FALSE,
               mode = "file")
    path <- sanitize_path(path) # To kill trailing slashes
    
    usethis::write_over(glue("{path}/DESCRIPTION"), lines)
    cliapp::cli_alert_info("Please update the description fields, particularly the title, description and author")
  }
