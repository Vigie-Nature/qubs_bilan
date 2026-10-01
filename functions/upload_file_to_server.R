#######
# Functions to upload and download files from Vigie-Nature FTP
#######

#' Upload a file to ftp server
#'
#' @param file_to_upload file to upload
#' @param file_folder_local folder where your file is (local). must end with a / if not empty
#' @param file_folder_destination folder where you want to upload (server). must end with a / if not empty
#'
#' @return
#'
#' @examples
upload_file_to_server <- function (file_to_upload, file_folder_local = "", file_folder_destination = "") {
  # get permissions
  user = Sys.getenv("REPO_FTP_USER")
  password = Sys.getenv("REPO_FTP_PASSWORD")
  address = Sys.getenv("REPO_FTP_HOST")

  # upload file via ftp
  system(
    stringr::str_glue(
      'curl -p --insecure "ftp://{address}/{file_folder_destination}" --user "{user}:{password}" -T {file_folder_local}{file_to_upload} --ftp-create-dirs --ftp-ssl -k'
    )
  )
}
