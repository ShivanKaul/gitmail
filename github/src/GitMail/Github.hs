{-# LANGUAGE LambdaCase #-}

module GitMail.Github where

import           Data.List              ( isPrefixOf, intercalate )
import qualified Data.Text              as T
import           Github.Auth            as GA
import           Github.Issues          as GI
import           Github.Issues.Comments as GIC

import qualified GitMail.Email          as Email
import           GitMail.Types

-- | Construct an example "GithubConf"
defaultGithubConf :: GA.GithubAuth -> GithubConf
defaultGithubConf a = GithubConf { githubUser = "djeik"
                                 , githubRepo = "gitmail"
                                 , githubAuth = a
                                 }

-- | Checks whether an issue matches a given subject line.
doesIssueMatchSubject :: SubjectLine -> GI.Issue -> Bool
doesIssueMatchSubject s i = issueTitle i == T.unpack s

-- | Gets all the issues in the repository.
getIssues :: GithubConf -> IO (Either GI.Error [GI.Issue])
getIssues c = GI.issuesForRepo' (Just $ githubAuth c)
                                (githubUser c)
                                (githubRepo c)
                                []

-- | Finds a specific issue given its stripped email subject.
findIssue :: GithubConf -> SubjectLine -> IO (Either GI.Error
                                                     (Either UniquenessError
                                                             GI.Issue))
findIssue c s = do
    issues <- getIssues c
    pure $ do
        issues >>= pure . \case
            [] -> Left $ NoResults
            [x] -> pure x
            xs -> Left $ TooManyResults

-- | Opens a new issue.
createIssue :: GithubConf -> GI.NewIssue -> IO (Either GI.Error GI.Issue)
createIssue c n = GI.createIssue (githubAuth c)
                                 (githubUser c)
                                 (githubRepo c)
                                 n

createComment :: GithubConf -> Int -> String -> IO (Either GI.Error GI.Comment)
createComment c n s = GIC.createComment (githubAuth c)
                                        (githubUser c)
                                        (githubRepo c)
                                        n
                                        s
