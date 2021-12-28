import { FC } from "react"

const chip: FC = ({ children }) => {
  return (<span className="text-xs text-blue-300 dark:bg-slate-600 bg-slate-300 py-1 px-2 rounded-md -mb-2">{children}</span>)
}

export default chip