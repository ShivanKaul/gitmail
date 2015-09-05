{-# LANGUAGE LambdaCase #-}

module GitMail.Github where

import           Data.List     ( isPrefixOf, intercalate )
import qualified Data.Text     as T
import           Github.Auth   as GA
import           Github.Issues as G

import qualified GitMail.Email as Email
import           GitMail.Types

-- | Construct an example "GithubConf"
defaultGithubConf :: GA.GithubAuth -> GithubConf
defaultGithubConf a = GithubConf { githubUser = "djeik"
                                 , githubRepo = "gitmail"
                                 , githubAuth = a
                                 }

-- | Checks whether an issue matches a given subject line.
doesIssueMatchSubject :: SubjectLine -> G.Issue -> Bool
doesIssueMatchSubject s i = issueTitle i == T.unpack s

-- | Gets all the issues in the repository.
getIssues :: GithubConf -> IO (Either G.Error [G.Issue])
getIssues c = G.issuesForRepo' (Just $ githubAuth c)
                               (githubUser c)
                               (githubRepo c)
                               []

-- | Finds a specific issue given its stripped email subject.
findIssue :: GithubConf -> SubjectLine -> IO (Either G.Error 
                                                     (Either UniquenessError 
                                                             G.Issue))
findIssue c s = do
    issues <- getIssues c
    pure $ do
        issues >>= pure . \case
            [] -> Left $ NoResults
            [x] -> pure x
            xs -> Left $ TooManyResults

-- | Opens a new issue.
createIssue :: GithubConf -> G.NewIssue -> IO (Either G.Error G.Issue)
createIssue c n = G.createIssue (githubAuth c)
                                (githubUser c)
                                (githubRepo c)
                                n
