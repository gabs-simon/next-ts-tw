import { FC } from "react"
import Chip from 'components/chip'

type HeadingInfoProps = {
  title: string
  chip: string
}
const headingInfo: FC<HeadingInfoProps> = ({ title, chip }) => {
  return (<>
    <Chip>{chip}</Chip>
    <h2 className="mt-1 mb-2">{title}</h2>
  </>
  )
}

export default headingInfo