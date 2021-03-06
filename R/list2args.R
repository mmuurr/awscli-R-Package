#' @rdname list2args
dots2args <- function(...) {
    list2args(list(...))
}


#' @title Convert a list to AWS CLI args
#' @param l A list of arguments to be mapped to AWS CLI args (using the AWS CLI's conventions).
#' #' @details
#'   Unnamed list entries are inserted into the system call as (positional) "<val>" arguments, i.e. with no argument-specifying hyphens.
#'   Named list entries are inserted into the system call with the "--<name> <val>" pattern.
#'   Any named list entries with a \code{NULL} value are inserted into the system call as "--<name>" but with no additional value, i.e. those arguments typically specify named flags.
#'   The final argument list is built in the order in which the args appear in `l`, so if an argument appears more than once in the list, there'll be multiple such args in the system call, too (in the same order in which they appear in the list).
#'   All final arguments are strings, so any non-character entry (in `l`) will be converted to a string using `as.character`; so for any arguments where the final string representation is important, be sure to pre-convert them to strings explicitly in the upstream call.
#' @examples
#' list2args(list("unnamed", "named" = "value", "flag" = NULL))
#' list2args(list("flag" = NULL, "flag" = NULL, "named1" = value1, "unnamed1", "named2" = "value2", "unnamed2"))
list2args <- function(l) {
    ## if l is unnamed, set all names "" (to prevent map2 problems downstream):
    if(is.null(names(l))) names(l) <- rep("", length(l))

    ## convert any NULL values to "":
    l <- purrr::map(l, function(x) if(is.null(x)) "" else x)

    ## safely convert to a single named character vector (and whitespace-trim values along the way).
    ## (`unlist` isn't type- and length-safe.)
    l <- purrr::map_chr(l, stringr::str_trim)

    ## trim the names and replace any name "x" with "--x".
    ## (leave "" names as-is.)
    names(l) <- names(l) %>%
        stringr::str_trim() %>%
        stringr::str_replace("(.+)", "--\\1")

    purrr::map2(names(l), l, c) %>% ## c() each (<name>,<value>) pair
        unlist() %>% ## collapse into a single character vector
        purrr::discard(stringr::str_length(.) == 0) ## remove any remaining empty args, which prunes the "" names
}
