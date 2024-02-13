import yaml from 'yaml'
import { YamlRequest } from ".";
import { readFile} from 'fs/promises'

// Name of the authenticated user, can be anything but needs to stay consistent across the YML file.
const userName = 'User'

/** Generate a YML string by merging the template file and options provided in the body. */
export default async (options: YamlRequest) => {
  const template = <YamlTemplate>yaml.parse(await readFile('./dist/template.yml', 'utf-8'))
  template.env.contexts[0].urls = options.urls

  if (options.username && options.password && options.loginUrl) {
    // Authenticated Scanning, populate YAML file with auth information
    template.env.contexts[0].users = [{
      name: userName,
      credentials: {
        username: options.username,
        password: options.password
      }
    }]
  
    template.env.contexts[0].authentication = {
      method: 'browser',
      parameters: {
        browserId: 'chrome-headless',
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
        pollUnits: 'seconds',
        pollPostData: ''
      }
    }

    // Make sure all jobs use this auth user
    for (const job of template.jobs) {
      job.parameters.user = userName
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
      authentication?: {
        method: 'browser'
        parameters?: {
          loginPageUrl: string
          loginPageWait: number
          browserId: 'firefox-headless' | 'chrome-headless'
        }
        verification?: {
          method: 'poll'
          loggedInRegex: string
          loggedOutRegex: string
          pollFrequency: number
          pollUnits: 'requests' | 'seconds'
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
  jobs: {
    name: 'spiderAjax' | 'activeScan'
    parameters: {
      url?: string
      user?: string
    }
  }[]
}