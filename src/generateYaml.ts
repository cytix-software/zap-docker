import yaml from 'yaml'
import { YamlRequest } from ".";
import { readFile} from 'fs/promises'

/** Generate a YML string by merging the template file and options provided in the body. */
export default async (options: YamlRequest) => {
  const template = <YamlTemplate>yaml.parse(await readFile('./src/template.yml', 'utf-8'))
  template.env.contexts[0].urls = [ options.url ]
  template.env.contexts[0].includePaths = [ options.url + '.*' ]

  template.env.contexts[0].users[0] = {
    name: 'User',
    credentials: {
      username: options.username,
      password: options.password
    }
  }

  if (options.loginUrl) {
    template.env.contexts[0].authentication.parameters = {
      browserId: 'firefox-headless',
      loginPageUrl: options.loginUrl,
      loginPageWait: 10
    }
  }
  if (options.pollUrl) {
    template.env.contexts[0].authentication.verification = {
      method: 'poll',
      pollUrl: options.pollUrl,
      loggedInRegex: options.loggedInRegex || '',
      loggedOutRegex: options.loggedOutRegex || '',
      pollFrequency: 60,
      pollUnits: 'requests',
      pollPostData: ''
    }
  }

  return yaml.stringify(template)
}

interface YamlTemplate {
  env: {
    contexts: {
      name: string
      urls?: string[]
      includePaths?: string[]
      excludePaths: string[]
      authentication: {
        method: 'browser'
        parameters?: {
          loginPageUrl: string
          loginPageWait: number
          browserId: 'firefox-headless'
        }
        verification?: {
          method: 'poll'
          loggedInRegex: string
          loggedOutRegex: string
          pollFrequency: number
          pollUnits: 'requests'
          pollUrl: string
          pollPostData: string
        }
      }
      sessionManagement: {
        method: string
      }
      users: {
        name: string
        credentials: {
          username: string
          password: string
        }
      }[]
    }[]
    parameters: {
      failOnError: boolean
      failOnWarning: boolean
      progressToStdout: boolean
    }
  }
  jobs: any[]
}