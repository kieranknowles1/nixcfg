export interface AppHeaderProps {
  name: string
  description: string
  iconSrc: string
}

export default function AppHeader(props: AppHeaderProps) {
  return <div className="flex">
    <div className="w-12 flex items-center justify-center">
      <img
        className="w-8"
        src={props.iconSrc}
      />
    </div>
    <div>
      <h3>{props.name}</h3>
      <h4>{props.description}</h4>
    </div>
  </div>
}
